# -*- encoding: utf-8 -*-

import nibabel.freesurfer.io as fsio
import nibabel.freesurfer.mghformat as fsmgh
import nibabel as nib
import os
import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sklearn.pipeline import Pipeline, FeatureUnion, make_pipeline
from sklearn.svm import LinearSVC, SVC
from sklearn.linear_model import LogisticRegression
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.naive_bayes import GaussianNB
from sklearn.ensemble import RandomForestClassifier
import dask_searchcv as dcv
from sklearn.model_selection import LeaveOneOut, RepeatedStratifiedKFold, StratifiedShuffleSplit, GridSearchCV, cross_val_score, cross_val_predict, learning_curve
from time import time
import sys
import csv
from sklearn.metrics import accuracy_score, confusion_matrix, classification_report, roc_curve, auc, roc_auc_score, precision_recall_curve, average_precision_score, f1_score
import matplotlib.pyplot as plt
import scikitplot as skplt
from math import sqrt, log2
from xgboost import XGBClassifier
from sklearn.neural_network import MLPClassifier
import pickle
from sklearn.feature_selection import SelectKBest, mutual_info_classif

# from tempfile import mkdtemp
# from shutil import rmtree
# from sklearn.externals.joblib import Memory

# balanced_accuracy_score = make_scorer(recall_score, pos_label=None, average='macro')
#
## Balanced accuracy defined in Neuropredict
def balanced_accuracy(y_true, y_pred):
    "Computes the balanced accuracy in a given confusion matrix!"

    confmat = confusion_matrix(y_true, y_pred)
    num_classes = confmat.shape[0]
    if num_classes != confmat.shape[1]:
        raise ValueError("given confusion matrix is not square!")

    confmat = confmat.astype(np.float64)

    indiv_class_acc = np.full([num_classes, 1], np.nan)
    for cc in range(num_classes):
        indiv_class_acc[cc] = confmat[cc, cc] / np.sum(confmat[cc, :])

    bal_acc = np.mean(indiv_class_acc)

    return bal_acc

## Create a function Calculating Number Of Components Required To Pass Threshold (LDA)
def select_n_components(var_ratio, goal_var: float) -> int:
    # Set initial variance explained so far
    total_variance = 0.0

    # Set initial number of features
    n_components = 0

    # For the explained variance of each feature:
    for explained_variance in var_ratio:

        # Add the explained variance to the total
        total_variance += explained_variance

        # Add one to the number of components
        n_components += 1

        # If we reach our goal level of explained variance
        if total_variance >= goal_var:
            # End the loop
            break

    # Return the number of components
    return n_components

## Utility function to report best scores
def report(results, n_top=3):
    for i in range(1, n_top + 1):
        candidates = np.flatnonzero(results['rank_test_score'] == i)
        for candidate in candidates:
            print("Model with rank: {0}".format(i))
            print("Mean validation score: {0:.7f} (std: {1:.7f})".format(
                  results['mean_test_score'][candidate],
                  results['std_test_score'][candidate]))# ## Utility function to report best scores
            print("Parameters: {0}".format(results['params'][candidate]))
            print("")

## function takes a RF parameter and a ranger and produces a plot and dataframe of CV scores for parameter values
def evaluate_param(clf, parameter, num_range, X, y):
    gs = GridSearchCV(clf, param_grid = { parameter: num_range }, cv = LeaveOneOut(), n_jobs = -1)
    gs.fit(X, y)

    acc = gs.cv_results_['mean_test_score']

    x_val = np.zeros(len(gs.cv_results_['mean_test_score']))
    for i, param_value in enumerate(gs.cv_results_['params']):
        x_val[i] = param_value[parameter]

    return x_val, acc

def load_raw_data(is_avail_csv = True, dir_csv = None, file_name_csv = None,
                is_surf_data = False, is_surf_binmask_user = False, dir_surf_data_mgh = None, file_name_surf_data_mgh = None,
                nb_class0 = None, nb_class1 = None, dir_csv_out = None, file_name_csv_out = None,
                dir_surf_binmask_user = None, file_name_surf_binmask_user = None, suffix_surf_binmask_user = None):
    """
    Load data from .csv file (1st column: label, 2-end columns: features) or from fsaverage surface overlay with/without user masking

    Parameters
    ----------
    is_avail_csv : bool
        Boolean determining if .csv file with labels and features is available (2D table [nb_subj, 1 + nb_features])

    dir_csv : str
        If is_avail_csv = True, directory containing the .csv file with labels and features

    file_name_csv : str
        If is_avail_csv = True, file name of the .csv with labels and features

    is_surf_data : bool
        Boolean determining if surface cortical data have to be loaded

    is_surf_binmask_user : bool
        Boolean determining if surface cortical user mask has to be loaded (default: cortical labels)

    dir_surf_data_mgh : str
        If is_surf_data = True, directory containing the .mgh surface data to load

    file_name_surf_data_mgh : str
        If is_surf_data = True, file name of the .mgh surface data to load

    nb_class0 : int
        If is_surf_data = True, number of subjects in class 0

    nb_class1 : int
        If is_surf_data = True, number of subjects in class 1

    dir_csv_out : str
        If is_surf_data = True, directory to save .csv file with the labels and features extracted from surface data

    file_name_csv_out : str
        If is_surf_data = True, file name of the .csv file with the labels and features extracted from surface data to save

    dir_surf_binmask_user : str
        If is_surf_binmask_user = True, directory containing the surface binary mask to load

    file_name_surf_binmask_user : str
        If is_surf_binmask_user = True, file name of the surface binary mask to load

    suffix_surf_binmask_user : str
        If is_surf_binmask_user = True, suffix extension (nii.gz or .mgh) of the surface binary mask to load

    Returns
    -------
    X : 2D numpy array [nb_subj, nb_features] of float32 containing all features

    y : 1D numpy array [nb_subj, ] of float32 containing all labels

    """

    if is_avail_csv == True:
        suffix = ".csv"
         ## Load .csv dataframe and create X features and y labels as np.ndarrays
        df = pd.read_csv(os.path.join(dir_csv, file_name_csv + suffix), header=None, dtype = np.float32)
        df = df.values
        X = df[:, 1:]
        y = df[:, 0]
    elif is_surf_data == True:
        ## Load Freesurfer .mgh file and return np.core.memmap.memmap[163842, 1, 1, nsubj] with values (float32)
        suffix = ".mgh"
        lh_X = nib.load(os.path.join(dir_surf_data_mgh, "lh." + file_name_surf_data_mgh + suffix))
        rh_X = nib.load(os.path.join(dir_surf_data_mgh, "rh." + file_name_surf_data_mgh + suffix))

        lh_X_data = lh_X.get_data()
        rh_X_data = rh_X.get_data()

        if is_surf_binmask_user == True:
            ## Load Freesurfer surface overlay (.nii.gz or .mgh) file and return np.ndarray[163842, 1, 1] with mask values (int32)
            lh_binmask = nib.load(os.path.join(dir_surf_binmask_user, "lh." + file_name_surf_binmask_user + suffix_surf_binmask_user))
            rh_binmask = nib.load(os.path.join(dir_surf_binmask_user, "rh." + file_name_surf_binmask_user + suffix_surf_binmask_user))

            lh_binmask_data = lh_binmask.get_data()
            rh_binmask_data = rh_binmask.get_data()

            ## Create boolean np.ndarray[163842, 1, 1] based on surface mask overlays
            lh_binmask_data_bool = lh_binmask_data.astype(np.bool)
            rh_binmask_data_bool = rh_binmask_data.astype(np.bool)

            ## Extract np.ndarray[nsubj, n_vertices_mask] vertices of interest on all patients with boolean arrays
            lh_X_data_binmask = lh_X_data[lh_binmask_data_bool]
            lh_X_data_binmask = lh_X_data_binmask.T
            rh_X_data_binmask = rh_X_data[rh_binmask_data_bool]
            rh_X_data_binmask = rh_X_data_binmask.T
        else:
            ## Load Freesurfer surface cortex .label file and return np.ndarray[149995] with indices of vertices included in cortex (int64)
            lh_ind_cortex = fsio.read_label("/home/global/freesurfer5.3/subjects/fsaverage/label/lh.cortex.label")
            rh_ind_cortex = fsio.read_label("/home/global/freesurfer5.3/subjects/fsaverage/label/rh.cortex.label")

            ## Extract np.ndarray[nsubj, n_vertices_mask] vertices of interest on all patients with integer indexing arrays
            lh_X_data_binmask = lh_X_data[lh_ind_cortex]
            lh_X_data_binmask = np.squeeze(lh_X_data_binmask).T
            rh_X_data_binmask = rh_X_data[rh_ind_cortex]
            rh_X_data_binmask = np.squeeze(rh_X_data_binmask).T

        ## Concatenate lh and rh vertices of interest
        X = np.concatenate((lh_X_data_binmask, rh_X_data_binmask), axis=1)

        ## Create labels array
        y = np.concatenate((np.zeros((nb_class0, 1), dtype = np.float32), np.ones((nb_class1, 1), dtype = np.float32)), axis=0)

        ## Concatenate labels and features arrays & save numpy 2D array into a .csv or .npy file
        input_ML = np.concatenate((y, X), axis=1)
        y = np.squeeze(y)
        df = pd.DataFrame(input_ML)
        df.to_csv(os.path.join(dir_csv_out, file_name_csv_out + ".csv"), header=None,  index=None)
        np.save(os.path.join(dir_csv_out, file_name_csv_out + ".npy"), input_ML)

    return X, y

def create_pipeline(X, y = None, is_reduce_dim = False, dim_reducer = "PCA", is_feature_sel = False, n_feat_selec = None,
                    classifier = "linear_svc", svc_kernel = "rbf", random_state = 42):

    """
    Create pipeline

    Parameters
    ----------
    X : float32
        2D numpy array [nb_subj, nb_features] containing all features

    y : float32
        1D numpy array [nb_subj, ] containing all labels

    is_reduce_dim : bool
        Boolean determining if dimensionality reduction method has to be used

    dim_reducer : str
        If is_reduce_dim = True, name of the dimensionality reduction method {"PCA", "LDA"}

    is_feature_sel : bool
        Boolean determining if selection feature by mutual information has to be used

    classifier : str
        Name of the estimator to use for classify data {"linear_svc", "svc", "lr", "lda", "gnb", "rf", "xgb", "mlp"}

    svc_kernel : str
        If classifier = "svc", name of the kernel to use {"rbf", "poly", "sigmoid"}

    random_state : int
        The seed of the pseudo random number generator to use

    Returns
    -------
    pipeline : Pipeline constructed according input parameters

    n_comp_pca : Number of components needed with PCA to get 0.99 of data variance

    n_comp_lda : Number of components needed with LDA to reach 0.99 of explained variance

    """

    steps = []
    n_comp_pca, n_comp_lda = None, None

    if is_reduce_dim == True:
        steps.append(("scaler", StandardScaler()))
        if dim_reducer == "PCA":
            ## Determine the number of outputed features
            scl = StandardScaler()
            X_std = scl.fit_transform(X)
            pca = PCA(n_components=0.99, random_state=random_state)
            X_std_pca = pca.fit_transform(X_std)
            n_comp_pca = X_std_pca.shape[1]
            if is_feature_sel == False:
                steps.append(("reduce_dim", PCA(n_components=0.99, random_state=random_state)))
            else:
                steps.append(("features_union", FeatureUnion([("reduce_dim", PCA(n_components=0.99, random_state=random_state)), ("feature_sel", SelectKBest(mutual_info_classif, k=n_feat_selec))])))
        elif dim_reducer == "LDA":
            ## Create and run an LDA
            scl = StandardScaler()
            X_std = scl.fit_transform(X)
            lda = LinearDiscriminantAnalysis(n_components=None, solver='svd', shrinkage=None)
            X_std_lda = lda.fit_transform(X_std, y)
            lda_var_ratios = lda.explained_variance_ratio_
            n_comp_lda = select_n_components(lda_var_ratios, 0.99)
            if is_feature_sel == False:
                steps.append(("reduce_dim", LinearDiscriminantAnalysis(n_components=n_comp_lda, solver='svd', shrinkage=None)))
            else:
                steps.append(("features_union", FeatureUnion([("reduce_dim", LinearDiscriminantAnalysis(n_components=n_comp_lda, solver='svd', shrinkage=None)), ("feature_sel", SelectKBest(mutual_info_classif, k=n_feat_selec))])))
    elif is_feature_sel == True:
        if X.shape[1] <= X.shape[0]:
            steps.append(("scaler", StandardScaler()))
            steps.append(("feature_sel", SelectKBest(mutual_info_classif)))
        else:
            # ## Create and fit SelectKBest in order to obtain n_components to reach mean scores
            # scl = StandardScaler()
            # X_std = scl.fit_transform(X)
            # feat_sel = SelectKBest(mutual_info_classif, k='all').fit(X_std,y)    # Create a temporary folder to store the transformers of the pipeline
            # print("Number of features with scores >= mean: ", np.sum((feat_sel.scores_ >= np.mean(feat_sel.scores_)).astype(np.int)))
            # n_feat_selec = np.sum((feat_sel.scores_ >= np.mean(feat_sel.scores_)).astype(np.int))
            steps.append(("scaler", StandardScaler()))
            steps.append(("feature_sel", SelectKBest(mutual_info_classif, k=n_feat_selec)))
    elif classifier == "linear_svc" or classifier == "svc" or classifier == "lr" or classifier == "mlp":
        steps.append(("scaler", StandardScaler()))

    if classifier == "linear_svc":
        if is_reduce_dim == True and dim_reducer == "PCA":
            if is_feature_sel == True:
                if (n_comp_pca+n_feat_selec) < X_std_pca.shape[0]:
                    steps.append(("linear_svc", LinearSVC(penalty="l2", loss="squared_hinge", dual=False, random_state=random_state)))
                else:
                    steps.append(("linear_svc", LinearSVC(penalty="l2", loss="squared_hinge", dual=True, random_state=random_state)))
            else:
                if n_comp_pca < X_std_pca.shape[0]:
                    steps.append(("linear_svc", LinearSVC(penalty="l2", loss="squared_hinge", dual=False, random_state=random_state)))
                else:
                    steps.append(("linear_svc", LinearSVC(penalty="l2", loss="squared_hinge", dual=True, random_state=random_state)))
        elif is_reduce_dim == True and dim_reducer == "LDA":
            if is_feature_sel == True:
                if (n_comp_lda+n_feat_selec) < X_std_lda.shape[0]:
                    steps.append(("linear_svc", LinearSVC(penalty="l2", loss="squared_hinge", dual=False, random_state=random_state)))
                else:
                    steps.append(("linear_svc", LinearSVC(penalty="l2", loss="squared_hinge", dual=True, random_state=random_state)))
            else:
                if n_comp_lda < X_std_lda.shape[0]:
                    steps.append(("linear_svc", LinearSVC(penalty="l2", loss="squared_hinge", dual=False, random_state=random_state)))
                else:
                    steps.append(("linear_svc", LinearSVC(penalty="l2", loss="squared_hinge", dual=True, random_state=random_state)))
        elif is_feature_sel == True:
            if n_feat_selec < X.shape[0]:
                steps.append(("linear_svc", LinearSVC(penalty="l2", loss="squared_hinge", dual=False, random_state=random_state)))
            else:
                steps.append(("linear_svc", LinearSVC(penalty="l2", loss="squared_hinge", dual=True, random_state=random_state)))
        else:
            if X.shape[1] < X.shape[0]:
                steps.append(("linear_svc", LinearSVC(penalty="l2", loss="squared_hinge", dual=False, random_state=random_state)))
            else:
                steps.append(("linear_svc", LinearSVC(penalty="l2", loss="squared_hinge", dual=True, random_state=random_state)))
    elif classifier == "svc":
        if svc_kernel == "rbf":
            steps.append(("svc", SVC(kernel="rbf", random_state=random_state)))
        elif svc_kernel == "poly":
            steps.append(("svc", SVC(kernel="poly", random_state=random_state)))
        elif svc_kernel == "sigmoid":
            steps.append(("svc", SVC(kernel="sigmoid", random_state=random_state)))
    elif classifier == "lr":
        if is_reduce_dim == True and dim_reducer == "PCA":
            if is_feature_sel == True:
                if (n_comp_pca+n_feat_selec) < X_std_pca.shape[0]:
                    steps.append(("lr", LogisticRegression(penalty='l2', dual=False, random_state=random_state)))
                else:
                    steps.append(("lr", LogisticRegression(penalty='l2', dual=True, random_state=random_state)))
            else:
                if n_comp_pca < X_std_pca.shape[0]:
                    steps.append(("lr", LogisticRegression(penalty='l2', dual=False, random_state=random_state)))
                else:
                    steps.append(("lr", LogisticRegression(penalty='l2', dual=True, random_state=random_state)))
        elif is_reduce_dim == True and dim_reducer == "LDA":
            if is_feature_sel == True:
                if (n_comp_lda+n_feat_selec) < X_std_lda.shape[0]:
                    steps.append(("lr", LogisticRegression(penalty='l2', dual=False, random_state=random_state)))
                else:
                    steps.append(("lr", LogisticRegression(penalty='l2', dual=True, random_state=random_state)))
            else:
                if n_comp_lda < X_std_lda.shape[0]:
                    steps.append(("lr", LogisticRegression(penalty='l2', dual=False, random_state=random_state)))
                else:
                    steps.append(("lr", LogisticRegression(penalty='l2', dual=True, random_state=random_state)))
        elif is_feature_sel == True:
            if n_feat_selec < X.shape[0]:
                steps.append(("lr", LogisticRegression(penalty='l2', dual=False, random_state=random_state)))
            else:
                steps.append(("lr", LogisticRegression(penalty='l2', dual=True, random_state=random_state)))
        else:
            if X.shape[1] < X.shape[0]:
                steps.append(("lr", LogisticRegression(penalty='l2', dual=False, random_state=random_state)))
            else:
                steps.append(("lr", LogisticRegression(penalty='l2', dual=True, random_state=random_state)))
    elif classifier == "mlp":
        # if is_reduce_dim == True or is_feature_sel == True:
        steps.append(("mlp", MLPClassifier(solver="lbfgs", random_state=random_state)))
        # else:
        #     steps.append(("mlp", MLPClassifier(solver="adam", random_state=random_state)))
    elif classifier == "lda":
        if is_reduce_dim == True or is_feature_sel == True:
            steps.append(("lda", LinearDiscriminantAnalysis(solver='lsqr', shrinkage=None)))
        else:
            steps.append(("lda", LinearDiscriminantAnalysis(solver='svd', shrinkage=None)))
    elif classifier == "gnb":
        steps.append(("gnb", GaussianNB()))
    elif classifier == "rf":
        if is_reduce_dim == True or is_feature_sel == True:
            steps.append(("rf", RandomForestClassifier(max_features=None, random_state=random_state)))
        else:
            steps.append(("rf", RandomForestClassifier(max_features="auto", random_state=random_state)))
    elif classifier == "xgb":
        steps.append(("xgb", XGBClassifier(seed=random_state)))

    # if is_reduce_dim == True or is_feature_sel == True:
    #     # Create a temporary folder to store the transformers of the pipeline
    #     cachedir = mkdtemp()
    #     memory = Memory(cachedir=cachedir, verbose=0)
    #     pipeline = Pipeline(steps,
    #                         memory=memory)
    # else:
    pipeline = Pipeline(steps)
    cachedir = None

    return pipeline, n_comp_pca, n_comp_lda, cachedir

def run_coarse_gridsearchCV(pipeline, X, y, dir_out, file_name_out, is_reduce_dim = False, dim_reducer = "PCA", is_feature_sel = False, n_feat_selec = None,
                            n_comp_pca = None, n_comp_lda = None, classifier = "linear_svc", svc_kernel = "rbf", metric = "accuracy", random_state = 42):

    """
    Create parameters grid according classifier type and run coarse hyperparameters optimization

    Parameters
    ----------
    pipeline : Pipeline obj
        Pipeline constructed according input parameters

    X : float32
        2D numpy array [nb_subj, nb_features]  containing all features

    y : float32
        1D numpy array [nb_subj, ] containing all labels

    dir_out : str
        Directory to save the file containing metrics & time results

    file_name_out : str
        File name containing metrics  & time results

    is_reduce_dim : bool
        Boolean determining if dimensionality reduction method has to be used

    dim_reducer : str
        If is_reduce_dim = True, name of the dimensionality reduction method {"PCA", "LDA"}

    is_feature_sel : bool
        Boolean determining if selection feature by mutual information has to be used

    n_comp_pca : int
        Number of components needed with PCA to get 0.99 of data variance

    n_comp_lda : int
        Number of components needed with LDA to reach 0.99 of explained variance

    classifier : str
        Name of the estimator used for classifying data {"linear_svc", "svc", "lr", "lda", "gnb", "rf", "xgb", "mlp"}

    svc_kernel : str
        If classifier = "svc", name of the kernel to use {"rbf", "poly", "sigmoid"}

    random_state : int
        The seed of the pseudo random number generator to use

    Returns
    -------
    param_grid : Parameters grid according classifier type for use in hyperparameters optimizing

    gs_coarse : Coarse GridSearchCV fitted

    """
    if classifier == "lda" or classifier == "gnb":
        param_grid = {}
    elif classifier == "linear_svc":
        C_range = np.logspace(-25, 15, 41, base = 2)
        param_grid = {
                        "linear_svc__C": C_range
                    }
    elif classifier == "svc":
        C_range = np.logspace(-25, 15, 41, base = 2)
        Gamma_range = np.logspace(-15, 5, 21, base = 2)
        if svc_kernel == "rbf":
            param_grid = {
                            "svc__C": C_range,
                            "svc__gamma": Gamma_range
                        }
        elif svc_kernel == "poly":
            degree_range = np.array([2, 3, 4, 5, 6])
            param_grid = {
                            "svc__C": C_range,
                            "svc__gamma": Gamma_range,
                            "svc__degree": degree_range
                        }
        elif svc_kernel == "sigmoid":
            param_grid = {
                            "svc__C": C_range,
                            "svc__gamma": Gamma_range
                        }
    elif classifier == "lr":
        C_range = np.logspace(-25, 15, 41, base = 2)
        param_grid = {
                        "lr__C": C_range
                    }
    elif classifier == "rf":
        # range_num_trees = np.arange(50,550,50)
        range_num_trees = np.arange(50,550,50)
        # range_max_features = np.array([np.rint(sqrt(X.shape[1])).astype(np.int), X.shape[1]])
        # min_samples_split_range = [2, 5, 10, 15]
        # split_criteria      = ['gini', 'entropy']
        range_min_leafsize = np.concatenate(([1, 3], np.arange(5,25,5)))
        # range_min_impurity  = np.arange(0., 0.41, 0.1)
        range_bootstrap = [True, False]

        param_grid = {
                        "rf__n_estimators": range_num_trees,
                        "rf__min_samples_leaf": range_min_leafsize,
                        # "rf__max_features": range_max_features,
                        # "rf__min_impurity_decrease": range_min_impurity, # ignoring this
                        "rf__bootstrap": range_bootstrap
                    }
    elif classifier == "xgb":
        range_num_trees = np.arange(50,550,50)
        range_max_depth = np.concatenate(([1, 3], np.arange(5,25,5)))
        range_gamma = np.array([0,5,10])
        range_min_child_weight = np.array([1,3,5,10])

        param_grid = {
                        "xgb__n_estimators": range_num_trees,
                        "xgb__max_depth": range_max_depth,
                        "xgb__gamma": range_gamma,
                        "xgb__min_child_weight": range_min_child_weight
                    }
    elif classifier == "mlp":
        if is_reduce_dim == True and dim_reducer == "PCA":
            if is_feature_sel == True:
                hl_sizes_range = [(np.rint(1/3*(n_comp_pca+n_feat_selec)).astype(np.int),), (np.rint(2/3*(n_comp_pca+n_feat_selec)).astype(np.int),), (n_comp_pca+n_feat_selec,),
                        (2*(n_comp_pca+n_feat_selec),), (3*(n_comp_pca+n_feat_selec),), (4*(n_comp_pca+n_feat_selec),), (5*(n_comp_pca+n_feat_selec),), (6*(n_comp_pca+n_feat_selec),)]
            else:
                hl_sizes_range = [(np.rint(1/3*n_comp_pca).astype(np.int),), (np.rint(2/3*n_comp_pca).astype(np.int),), (n_comp_pca,),
                        (2*n_comp_pca,), (3*n_comp_pca,), (4*n_comp_pca,), (5*n_comp_pca,), (6*n_comp_pca,)]
        elif is_reduce_dim == True and dim_reducer == "LDA":
            if is_feature_sel == True:
                hl_sizes_range = [(np.rint(1/3*(n_comp_lda+n_feat_selec)).astype(np.int),), (np.rint(2/3*(n_comp_lda+n_feat_selec)).astype(np.int),), (n_comp_lda+n_feat_selec,),
                        (2*(n_comp_lda+n_feat_selec),), (3*(n_comp_lda+n_feat_selec),), (4*(n_comp_lda+n_feat_selec),), (5*(n_comp_lda+n_feat_selec),), (6*(n_comp_lda+n_feat_selec),)]
            else:
                hl_sizes_range = [(n_comp_lda,), (2*n_comp_lda,), (3*n_comp_lda,), (4*n_comp_lda,), (5*n_comp_lda,), (6*n_comp_lda,)]
        elif is_feature_sel == True:
                hl_sizes_range = [(np.rint(1/3*n_feat_selec).astype(np.int),), (np.rint(2/3*n_feat_selec).astype(np.int),), (n_feat_selec,),
                        (2*n_feat_selec,), (3*n_feat_selec,), (4*n_feat_selec,), (5*n_feat_selec,), (6*n_feat_selec,)]
        else:
            if X.shape[1] < X.shape[0]:
                hl_sizes_range = [(np.rint(1/3*X.shape[1]).astype(np.int),), (np.rint(2/3*X.shape[1]).astype(np.int),), (X.shape[1],),
                        (2*X.shape[1],), (3*X.shape[1],), (4*X.shape[1],), (5*X.shape[1],), (6*X.shape[1],)]
            else:
                hl_sizes_range = [(np.rint(1/3*X.shape[0]).astype(np.int),), (np.rint(2/3*X.shape[0]).astype(np.int),), (X.shape[0],),
                        (2*X.shape[0],), (4*X.shape[0],)]

        alpha_range = np.logspace(-20, 5, 26, base = 2)
        param_grid = {
                        "mlp__alpha": alpha_range,
                        "mlp__hidden_layer_sizes": hl_sizes_range
                    }

    # Manage features selection
    if is_feature_sel == True:
        if is_reduce_dim == False:
            if X.shape[1] <= 5*X.shape[0]:
                k_range = np.linspace(1, X.shape[1], num=25, dtype=np.int)
                k_range = np.unique(k_range)
                param_grid.update({"feature_sel__k": k_range})
    if is_reduce_dim == True:
        if dim_reducer == "PCA":
            print("Number of PCA components to reach 0.99 of explained variance: %i" % n_comp_pca, file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
        elif dim_reducer == "LDA":
            print("Number of LDA components to reach 0.99 of explained variance: %i" % n_comp_lda, file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))

    if bool(param_grid):
        if len(pipeline.steps) > 2 and is_reduce_dim == True and is_feature_sel == False:
            if classifier == "rf":
                ## Define dask GridSearchCV multiprocessing
                print("dask gridsearch multiprocessing", file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
                gs_coarse = dcv.GridSearchCV(estimator=pipeline,
                                                  param_grid=param_grid,
                                                  scoring=metric,
                                                  cv=LeaveOneOut(),
                                                  n_jobs=-1,
                                                  scheduler="multiprocessing")
            else:
                ## Define dask GridSearchCV threading
                print("dask GridSearchCV threading", file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
                gs_coarse = dcv.GridSearchCV(estimator=pipeline,
                                                  param_grid=param_grid,
                                                  scoring=metric,
                                                  cv=LeaveOneOut(),
                                                  n_jobs=-1,
                                                  scheduler="threading")
        elif len(pipeline.steps) > 2 and is_feature_sel == True:
            ## Define dask GridSearchCV multiprocessing
            print("dask gridsearch multiprocessing", file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
            gs_coarse = dcv.GridSearchCV(estimator=pipeline,
                                              param_grid=param_grid,
                                              scoring=metric,
                                              cv=LeaveOneOut(),
                                              n_jobs=-1,
                                              scheduler="multiprocessing")
        else:
            ## Define sklearn GridSearchCV
            print("sklearn gridsearch multiprocessing", file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
            gs_coarse = GridSearchCV(estimator=pipeline,
                                      param_grid=param_grid,
                                      scoring=metric,
                                      cv=LeaveOneOut(),
                                      n_jobs=-1)

        ## Evaluate GridSearchCV results
        print("Tuning hyper-parameters for scoring")
        print()
        start = time()
        gs_coarse.fit(X, y)
        print("Best parameters set found on development set:")
        print()
        print(gs_coarse.best_params_)
        print(gs_coarse.best_score_)
        print()
        print("GridSearchCV took %.2f seconds for %d candidate parameter settings."
              % (time() - start, len(gs_coarse.cv_results_['params'])))
        print("GridSearchCV took %.2f seconds for %d candidate parameter settings" % (time() - start, len(gs_coarse.cv_results_['params'])), file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
        # report(gs_coarse.cv_results_, 3)
        print()

        # print("Grid scores on development set:")
        # print()
        # means = gs_coarse.cv_results_['mean_test_score']
        # stds = gs_coarse.cv_results_['std_test_score']
        # for mean, std, params in zip(means, stds, gs_coarse.cv_results_['params']):
        #     print("%0.3f (+/-%0.03f) for %r"
        #           % (mean, std * 2, params))
        # print()
    else:
        param_grid, gs_coarse = None, None

    return param_grid, gs_coarse

def compute_svc_fine_range(param_grid, gs_coarse, svc_field_name):

    """
    Compute svc_fine_range for CV

    Parameters
    ----------
    param_grid : Parameters grid according classifier type for use in hyperparameters optimizing

    gs_coarse : Coarse GridSearchCV fitted

    Returns
    -------
    svc_fine_range : float32
        Fine range of C or Gamma values to apply to CV, from coarse gridsearch results

    """

    svc_opt=gs_coarse.best_params_[svc_field_name]
    print("svc coarse optimal parameter: %.7f" % svc_opt)
    ind_svc = np.where(param_grid[svc_field_name]==svc_opt)
    print("Position of svc coarse optimal parameter in svc_range: %i" % ind_svc[0])

    if (ind_svc[0]-1) >= 0:
        if (ind_svc[0]+1) <= (len(param_grid[svc_field_name])-1):
            r1 = np.linspace(param_grid[svc_field_name][ind_svc[0]-1], svc_opt, num=3)
            r2 = np.linspace(svc_opt, param_grid[svc_field_name][ind_svc[0]+1], num=3)
            svc_fine_range = np.concatenate((r1[1:], r2[1:r2.shape[0]-1]))
            print()
            print("svc_fine_range:", svc_fine_range)
            print()
        else:
            r1 = np.linspace(param_grid[svc_field_name][ind_svc[0]-1], svc_opt, num=3)
            svc_fine_range = r1[1:]
            print()
            print("svc_fine_range:", svc_fine_range)
            print()
    else:
        r2 = np.linspace(svc_opt, param_grid[svc_field_name][ind_svc[0]+1], num=3)
        svc_fine_range = r2[:r2.shape[0]-1]
        print()
        print("svc_fine_range:", svc_fine_range)
        print()

    return svc_fine_range

def compute_rf_int_fine_range(param_grid, gs_coarse, rf_int_field_name):

    """
    Compute rf_int_fine_range for CV

    Parameters
    ----------
    param_grid : Parameters grid according classifier type for use in hyperparameters optimizing

    gs_coarse : Coarse GridSearchCV fitted

    Returns
    -------
    rf_int_fine_range : int
        Fine range of rf_int to apply to CV, from coarse gridsearch results

    """
    rf_int_opt=gs_coarse.best_params_[rf_int_field_name]
    print(rf_int_field_name, " coarse optimal parameter: %i" % rf_int_opt)
    # ind_rf_int = param_grid[rf_int_field_name].index(rf_int_opt)
    ind_rf_int = np.where(param_grid[rf_int_field_name]==rf_int_opt)
    print("Position of ", rf_int_field_name, " coarse optimal parameter : %i" % ind_rf_int[0])

    if (ind_rf_int[0]-1) >= 0:
        if (ind_rf_int[0]+1) <= (len(param_grid[rf_int_field_name])-1):
            r1 = np.linspace(param_grid[rf_int_field_name][ind_rf_int[0]-1], rf_int_opt, num=3)
            r2 = np.linspace(rf_int_opt, param_grid[rf_int_field_name][ind_rf_int[0]+1], num=3)
            rf_int_fine_range = np.concatenate((r1[1:], r2[1:r2.shape[0]-1]))
            rf_int_fine_range = np.unique(np.rint(rf_int_fine_range).astype(np.int))
            print()
            print(rf_int_field_name,"_fine_range:", rf_int_fine_range)
            print()
        else:
            r1 = np.linspace(param_grid[rf_int_field_name][ind_rf_int[0]-1], rf_int_opt, num=3)
            rf_int_fine_range = r1[1:]
            rf_int_fine_range = np.unique(np.rint(rf_int_fine_range).astype(np.int))
            print()
            print(rf_int_field_name,"_fine_range:", rf_int_fine_range)
            print()
    else:
        r2 = np.linspace(rf_int_opt, param_grid[rf_int_field_name][ind_rf_int[0]+1], num=3)
        rf_int_fine_range = r2[:r2.shape[0]-1]
        rf_int_fine_range = np.unique(np.rint(rf_int_fine_range).astype(np.int))
        print()
        print(rf_int_field_name,"_fine_range:", rf_int_fine_range)
        print()

    return rf_int_fine_range

def compute_mlp_tuple_fine_range(param_grid, gs_coarse, mlp_tuple_field_name):

    """
    Compute mlp_tuple_fine_range for CV

    Parameters
    ----------
    param_grid : Parameters grid according classifier type for use in hyperparameters optimizing

    gs_coarse : Coarse GridSearchCV fitted

    Returns
    -------
    mlp_tuple_fine_range : tuple
        Fine range of mlp_tuple to apply to CV, from coarse gridsearch results

    """
    mlp_tuple_opt=gs_coarse.best_params_[mlp_tuple_field_name]
    print(mlp_tuple_field_name, " coarse optimal parameter: %s" % mlp_tuple_opt)
    ind_mlp_tuple = param_grid[mlp_tuple_field_name].index(mlp_tuple_opt)
    # ind_mlp_tuple = np.where(param_grid[mlp_tuple_field_name]==mlp_tuple_opt)
    print("Position of ", mlp_tuple_field_name, " coarse optimal parameter : %i" % ind_mlp_tuple)

    if (ind_mlp_tuple-1) >= 0:
        if (ind_mlp_tuple+1) <= (len(param_grid[mlp_tuple_field_name])-1):
            r1 = np.linspace(param_grid[mlp_tuple_field_name][ind_mlp_tuple-1][0], mlp_tuple_opt[0], num=3)
            r2 = np.linspace(mlp_tuple_opt[0], param_grid[mlp_tuple_field_name][ind_mlp_tuple+1][0], num=3)
            mlp_tuple_fine_range = np.concatenate((r1[1:], r2[1:r2.shape[0]-1]))
            mlp_tuple_fine_range = np.unique(np.rint(mlp_tuple_fine_range).astype(np.int))
            mlp_tuple_fine_range = mlp_tuple_fine_range.tolist()
            for i in range(len(mlp_tuple_fine_range)):
                mlp_tuple_fine_range[i] = (mlp_tuple_fine_range[i],)
            print()
            print(mlp_tuple_field_name,"_fine_range:", mlp_tuple_fine_range)
            print()

        else:
            r1 = np.linspace(param_grid[mlp_tuple_field_name][ind_mlp_tuple-1][0], mlp_tuple_opt[0], num=3)
            mlp_tuple_fine_range = r1[1:]
            mlp_tuple_fine_range = np.unique(np.rint(mlp_tuple_fine_range).astype(np.int))
            mlp_tuple_fine_range = mlp_tuple_fine_range.tolist()
            for i in range(len(mlp_tuple_fine_range)):
                mlp_tuple_fine_range[i] = (mlp_tuple_fine_range[i],)
            print()
            print(mlp_tuple_field_name,"_fine_range:", mlp_tuple_fine_range)
            print()
    else:
        r2 = np.linspace(mlp_tuple_opt[0], param_grid[mlp_tuple_field_name][ind_mlp_tuple+1][0], num=3)
        mlp_tuple_fine_range = r2[:r2.shape[0]-1]
        mlp_tuple_fine_range = np.unique(np.rint(mlp_tuple_fine_range).astype(np.int))
        mlp_tuple_fine_range = mlp_tuple_fine_range.tolist()
        for i in range(len(mlp_tuple_fine_range)):
            mlp_tuple_fine_range[i] = (mlp_tuple_fine_range[i],)
        print()
        print(mlp_tuple_field_name,"_fine_range:", mlp_tuple_fine_range)
        print()

    return mlp_tuple_fine_range

def run_fine_CV(pipeline, X, y, dir_out, file_name_out, name_class0, name_class1, param_grid = None, gs_coarse = None,
                is_reduce_dim = False, dim_reducer = "PCA", is_feature_sel = False, n_comp_pca = None, n_comp_lda = None,
                classifier = "linear_svc", svc_kernel = "rbf", metric = "accuracy"):

    """
    Run LOO CV or nested CV based on classifier type and fine range of hyperparameters

    Parameters
    ----------
    pipeline : Pipeline constructed according input parameters

    X : float32
        2D numpy array [nb_subj, nb_features]  containing all features

    y : float32
        1D numpy array [nb_subj, ] containing all labels

    dir_out : str
        Directory to save the file containing metrics results

    file_name_out : str
        File name containing metrics results

    name_class0 : str
        Name of the class 0

    name_class1 : str
        Name of the class 1

    param_grid : Parameters grid according classifier type for use in hyperparameters optimizing

    gs_coarse : Coarse GridSearchCV fitted

    is_reduce_dim : bool
        Boolean determining if dimensionality reduction method has to be used

    dim_reducer : str
        If is_reduce_dim = True, name of the dimensionality reduction method {"PCA", "LDA"}

    is_feature_sel : bool
        Boolean determining if selection feature by mutual information has to be used

    n_comp_pca : int
        Number of components needed with PCA to get 0.99 of data variance

    n_comp_lda : int
        Number of components needed with LDA to reach 0.99 of explained variance

    classifier : str
        Name of the estimator used for classifying data {"lda", "gnb", "linear_svc", "svc", "lr", "rf", "xgb", "mlp"}

    svc_kernel : str
        If classifier = "svc", name of the kernel to use {"rbf", "poly", "sigmoid"}

    metric : str
        Metric used to evaluate performance of the classifier

    Returns
    -------
    y_pred : Prediction of labels on output of CV

    confmat : Confusion matrix on output of CV

    accuracy : Accuracy on output of CV

    bal_acc : Balanced accuracy on output of CV

    classif_report : Classification report table (precision, recall, f1-score) on output of CV

    """

    ## Print in file GridSearch best results
    if param_grid != None:
        print("GridSearchCV best estimator: ", gs_coarse.best_estimator_,file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
        print("GridSearchCV best parameters: ", gs_coarse.best_params_,file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
        print("GridSearchCV best scoring: ", gs_coarse.best_score_,file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
        print()

    ## Set number of features selected to best GridSearch values
    if is_feature_sel == True:
        if is_reduce_dim == False:
            if X.shape[1] <= 5*X.shape[0]:
                pipeline.set_params(feature_sel__k=gs_coarse.best_params_["feature_sel__k"])
        # else:
        #     pipeline.set_params(features_union__feature_sel__k=gs_coarse.best_params_["features_union__feature_sel__k"])

    ## Define LOO cross-validation only when no hyperparameter to optimize ##
    if classifier == "lda" or classifier == "gnb":
        print("Running LOO cross-validation")
        print()
        start = time()
        y_pred = cross_val_predict(pipeline, X, y, cv=LeaveOneOut(), n_jobs=-1)
        print("LOO cross-validation took %.2f seconds" % (time() - start))
        print("LOO cross-validation took %.2f seconds" % (time() - start), file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
        print()

    ## Define LOO nested cross-validation else ##
    elif classifier == "linear_svc" or classifier == "svc" or classifier == "lr" or classifier == "rf" or classifier == "xgb" or classifier == "mlp":

        if classifier == "linear_svc":
            C_fine_range = compute_svc_fine_range(param_grid, gs_coarse, "linear_svc__C")
            param_grid = {
                            "linear_svc__C": C_fine_range
                        }
        elif classifier == "svc":
            C_fine_range = compute_svc_fine_range(param_grid, gs_coarse, "svc__C")
            Gamma_fine_range = compute_svc_fine_range(param_grid, gs_coarse, "svc__gamma")
            param_grid = {
                            "svc__C": C_fine_range,
                            "svc__gamma": Gamma_fine_range
                        }
            if svc_kernel == "poly":
                pipeline.set_params(svc__degree=gs_coarse.best_params_["svc__degree"])

        elif classifier == "lr":
            C_fine_range = compute_svc_fine_range(param_grid, gs_coarse, "lr__C")
            param_grid = {
                            "lr__C": C_fine_range
                        }
        elif classifier == "rf":
            min_samples_leaf_fine_range = compute_rf_int_fine_range(param_grid, gs_coarse, "rf__min_samples_leaf")
            # max_features_fine_range = compute_rf_int_fine_range(param_grid, gs_coarse, "rf__max_features")
            param_grid = [{
                            "rf__min_samples_leaf": min_samples_leaf_fine_range
                            # "rf__max_features": max_features_fine_range
                        }]
            pipeline.set_params(rf__n_estimators=gs_coarse.best_params_["rf__n_estimators"])
            pipeline.set_params(rf__bootstrap=gs_coarse.best_params_["rf__bootstrap"])

        elif classifier == "xgb":
            num_trees_fine_range = compute_rf_int_fine_range(param_grid, gs_coarse, "xgb__n_estimators")
            # max_depth_fine_range = compute_rf_int_fine_range(param_grid, gs_coarse, "xgb__max_depth")
            param_grid = [{
                            "xgb__n_estimators": num_trees_fine_range
                            # "xgb__max_depth": max_depth_fine_range
                        }]
            pipeline.set_params(xgb__gamma=gs_coarse.best_params_["xgb__gamma"])
            pipeline.set_params(xgb__min_child_weight=gs_coarse.best_params_["xgb__min_child_weight"])
            pipeline.set_params(xgb__max_depth=gs_coarse.best_params_["xgb__max_depth"])

        elif classifier == "mlp":
            alpha_fine_range = compute_svc_fine_range(param_grid, gs_coarse, "mlp__alpha")
            hl_sizes_fine_range = compute_mlp_tuple_fine_range(param_grid, gs_coarse, "mlp__hidden_layer_sizes")
            param_grid = {
                            "mlp__alpha": alpha_fine_range,
                            "mlp__hidden_layer_sizes": hl_sizes_fine_range
                        }

        ## Define LOO nested cross-validation based on fine range of parameters ##
        if len(pipeline.steps) > 2:
            ## Define dask GridSearchCV
            gs_fine = dcv.GridSearchCV(estimator=pipeline,
                                        param_grid=param_grid,
                                        scoring=metric,
                                        cv=LeaveOneOut(),
                                        n_jobs=1)
                                        # scheduler="multiprocessing")
                                        # scheduler="threading")
        else:
            ## Define sklearn GridSearchCV
            gs_fine = GridSearchCV(estimator=pipeline,
                                      param_grid=param_grid,
                                      scoring=metric,
                                      cv=LeaveOneOut(),
                                      n_jobs=1)

        # print("Running LOO nested cross-validation scoring")
        # print()
        # start = time()
        # scores = cross_val_score(gs_fine, X, y, scoring='roc_auc', cv=LeaveOneOut(), n_jobs=-1)
        # print("LOO nested cross-validation scoring took %.2f seconds" % (time() - start))
        # print("LOO nested cross-validation scoring took %.2f seconds" % (time() - start), file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
        # print('CV AUC: %.4f +/- %.4f' % (np.mean(scores), np.std(scores)))
        # print('CV AUC: %.4f +/- %.4f' % (np.mean(scores), np.std(scores)), file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
        # print()

        print("Running LOO nested cross-validation prediction")
        print()
        start = time()
        y_pred = cross_val_predict(gs_fine, X, y, cv=LeaveOneOut(), n_jobs=-1)
        print("LOO nested cross-validation prediction took %.2f seconds" % (time() - start))
        print("LOO nested cross-validation prediction took %.2f seconds" % (time() - start), file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))

    with open(os.path.join(dir_out, file_name_out + ".csv"), "w") as f:
        writer = csv.writer(f, delimiter='\t')
        writer.writerows(zip(y, y_pred))
    print()
    confmat = confusion_matrix(y, y_pred)
    print("Confusion matrix: ")
    print(confmat)
    print()
    print("Confusion matrix:", file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
    print(confmat,file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
    accuracy = accuracy_score(y, y_pred)
    print("Accuracy score: %.4f" % accuracy)
    print()
    print("Accuracy score: %.4f" % accuracy,file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
    bal_acc = balanced_accuracy(y, y_pred)
    print("Balanced accuracy: %.4f" % bal_acc)
    print()
    print("Balanced accuracy: %.4f" % bal_acc,file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
    target_names = [name_class0, name_class1]
    classif_report = classification_report(y, y_pred, target_names=target_names, digits=4)
    print("Classification report: ")
    print(classification_report(y, y_pred, target_names=target_names, digits=4))
    print()
    print("Classification report: ", file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
    print(classification_report(y, y_pred, target_names=target_names, digits=4),file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
    print()

    ## Save graphic containing the normalized confusion matrix
    skplt.metrics.plot_confusion_matrix(y, y_pred, normalize=True)
    plt.savefig(os.path.join(dir_out, "ConfMat_" + file_name_out + ".png"),dpi=300)
    plt.close('all')

    return pipeline, y_pred, confmat, accuracy, bal_acc, classif_report

def run_perf_best_estimator(pipeline, X_train, y_train, X_test, y_test, dir_out, file_name_out,
                            name_class0, name_class1, param_grid = None, gs_coarse = None):

    """
    Estimate the performance of the best GridSearchCV estimator

    Parameters
    ----------
    pipeline : Pipeline constructed according input parameters

    X_train : float32
        2D numpy array [nb_subj, nb_features]  containing all train features

    y_train : float32
        1D numpy array [nb_subj, ] containing all train labels

    X_test : float32
        2D numpy array [nb_subj, nb_features]  containing all test features

    y_test : float32
        1D numpy array [nb_subj, ] containing all test labels

    dir_out : str
        Directory to save the file containing metrics results

    file_name_out : str
        File name containing metrics results

    name_class0 : str
        Name of the class 0

    name_class1 : str
        Name of the class 1

    param_grid : Parameters grid according classifier type for use in hyperparameters optimizing

    gs_coarse : Coarse GridSearchCV fitted

    Returns
    -------
    y_pred : Prediction of labels of test set

    confmat : Confusion matrix based on test set prediction

    accuracy : Accuracy based on test set prediction

    bal_acc : Balanced accuracy based on test set prediction

    classif_report : Classification report table (precision, recall, f1-score) based on test set prediction

    """

    ## Print in file GridSearch best results
    if param_grid != None:
        print("GridSearchCV best estimator: ", gs_coarse.best_estimator_,file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
        print("GridSearchCV best parameters: ", gs_coarse.best_params_,file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
        print("GridSearchCV best scoring: ", gs_coarse.best_score_,file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
        print()

        ## Evaluation of the performance of the best estimator on the test set
        # clf = gs_coarse.best_estimator_
        # clf.fit(X_train, y_train)
        # y_pred = clf.predict(X_test)
        y_pred = gs_coarse.predict(X_test)

    ## For lda and gnb with no feature selection: fit model on train set and predict on test set
    else:
        print("Fit pipeline on train set")
        print("Fit pipeline on train set",file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
        pipeline.fit(X_train, y_train)
        print("Predict pipeline on test set")
        print("Predict pipeline on test set",file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
        y_pred = pipeline.predict(X_test)
        print()

    with open(os.path.join(dir_out, file_name_out + ".csv"), "w") as f:
        writer = csv.writer(f, delimiter='\t')
        writer.writerows(zip(y_test, y_pred))
    print()
    confmat = confusion_matrix(y_test, y_pred)
    print("Confusion matrix: ")
    print(confmat)
    print()
    print("Confusion matrix:", file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
    print(confmat,file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
    accuracy = accuracy_score(y_test, y_pred)
    print("Accuracy score: %.4f" % accuracy)
    print()
    print("Accuracy score: %.4f" % accuracy,file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
    bal_acc = balanced_accuracy(y_test, y_pred)
    print("Balanced accuracy: %.4f" % bal_acc)
    print()
    print("Balanced accuracy: %.4f" % bal_acc,file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
    target_names = [name_class0, name_class1]
    classif_report = classification_report(y_test, y_pred, target_names=target_names, digits=4)
    print("Classification report: ")
    print(classification_report(y_test, y_pred, target_names=target_names, digits=4))
    print()
    print("Classification report: ", file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
    print(classification_report(y_test, y_pred, target_names=target_names, digits=4),file=open(os.path.join(dir_out, file_name_out + ".txt"), "a"))
    print()

    ## Save graphic containing the normalized confusion matrix
    skplt.metrics.plot_confusion_matrix(y_test, y_pred, normalize=True)
    plt.savefig(os.path.join(dir_out, "ConfMat_" + file_name_out + ".png"),dpi=300)
    plt.close('all')

    return pipeline, y_pred, confmat, accuracy, bal_acc, classif_report

def save_fig(PROJECT_ROOT_DIR, fig_id, tight_layout=True):
    path = os.path.join(PROJECT_ROOT_DIR, fig_id + ".png")
    print("Saving figure", fig_id)
    if tight_layout:
        plt.tight_layout()
    plt.savefig(path, format='png', dpi=300)
    # plt.cla()

def plot_roc_curve(fpr, tpr, color, label):
    fig = plt.figure(figsize=(7, 5))
    plt.plot(fpr, tpr, color=color, label=label, linewidth=2)
    plt.plot([0, 1], [0, 1], 'k--', label='random guessing')
    plt.axis([0, 1, 0, 1])
    plt.xlabel('False Positive Rate', fontsize=14)
    plt.ylabel('True Positive Rate', fontsize=14)
    plt.plot([0, 0, 1],
             [0, 1, 1],
             linestyle=':',
             color='black',
             label='perfect performance')
    plt.xlim([-0.05, 1.05])
    plt.ylim([-0.05, 1.05])
    plt.legend(loc="lower right")

def plot_precision_vs_recall(precisions, recalls, color, label):
    fig = plt.figure(figsize=(7, 5))
    plt.plot(recalls, precisions, color=color, label=label, linewidth=2)
    plt.xlabel("Recall", fontsize=14)
    plt.ylabel("Precision", fontsize=14)
    plt.axis([0, 1, 0, 1])
    plt.legend(loc="lower left")

def plot_learning_curve(estimator, title, X, y, ylim=None, cv=None, metric = "accuracy",
                        n_jobs=1, train_sizes=np.linspace(.1, 1.0, 10)):
    """
    Generate a simple plot of the test and training learning curve.

    Parameters
    ----------
    estimator : object type that implements the "fit" and "predict" methods
        An object of that type which is cloned for each validation.

    title : string
        Title for the chart.

    X : array-like, shape (n_samples, n_features)
        Training vector, where n_samples is the number of samples and
        n_features is the number of features.

    y : array-like, shape (n_samples) or (n_samples, n_features), optional
        Target relative to X for classification or regression;
        None for unsupervised learning.

    ylim : tuple, shape (ymin, ymax), optional
        Defines minimum and maximum yvalues plotted.

    cv : int, cross-validation generator or an iterable, optional
        Determines the cross-validation splitting strategy.
        Possible inputs for cv are:
          - None, to use the default 3-fold cross-validation,
          - integer, to specify the number of folds.
          - An object to be used as a cross-validation generator.
          - An iterable yielding train/test splits.

        For integer/None inputs, if ``y`` is binary or multiclass,
        :class:`StratifiedKFold` used. If the estimator is not a classifier
        or if ``y`` is neither binary nor multiclass, :class:`KFold` is used.

        Refer :ref:`User Guide <cross_validation>` for the various
        cross-validators that can be used here.

    metric : str
        Metric used to evaluate performance of the classifier

    n_jobs : integer, optional
        Number of jobs to run in parallel (default 1).

    train_sizes : array-like
        Array of percentage of training samples to use in learning curve
    """
    plt.figure()
    plt.title(title)
    if ylim is not None:
        plt.ylim(*ylim)
    plt.xlabel("Number of training samples")
    plt.ylabel("%s" % metric)
    train_sizes, train_scores, test_scores = learning_curve(
        estimator, X, y, cv=cv, n_jobs=n_jobs, train_sizes=train_sizes, scoring = metric)
    train_scores_mean = np.mean(train_scores, axis=1)
    train_scores_std = np.std(train_scores, axis=1)
    test_scores_mean = np.mean(test_scores, axis=1)
    test_scores_std = np.std(test_scores, axis=1)
    plt.grid()

    plt.fill_between(train_sizes, train_scores_mean - train_scores_std,
                     train_scores_mean + train_scores_std, alpha=0.15,
                     color="r")
    plt.fill_between(train_sizes, test_scores_mean - test_scores_std,
                     test_scores_mean + test_scores_std, alpha=0.15, color="g")
    plt.plot(train_sizes, train_scores_mean, 'o-', color="r",
             label="Training %s" % metric)
    plt.plot(train_sizes, test_scores_mean, 'o-', color="g",
             label="Cross-validation %s" % metric)

    plt.legend(loc="best")
    plt.tight_layout()

    return plt, train_sizes, train_scores_mean, train_scores_std, test_scores_mean, test_scores_std

def compute_graphic_metrics(pipeline, X, y, dir_out, file_name_out, param_grid = None, gs_coarse = None,
                            classifier = "linear_svc", svc_kernel = "rbf", n_splits = 20, is_reduce_dim = False,
                            dim_reducer = "PCA", is_feature_sel = False, random_state = 42, metric = "accuracy"):

    """
    Compute inputs for precision-recall or ROC curves, and learning curve based on LOO CV

    Parameters
    ----------
    pipeline : Pipeline constructed according input parameters

    X : float32
        2D numpy array [nb_subj, nb_features]  containing all features

    y : float32
        1D numpy array [nb_subj, ] containing all labels

    dir_out : str
        Directory to save the file containing metrics results

    file_name_out : str
        File name containing metrics results

    param_grid : Parameters grid according classifier type for use in hyperparameters optimizing

    gs_coarse : Coarse GridSearchCV fitted

    classifier : str
        Name of the estimator used for classifying data {"lda", "gnb", "linear_svc", "svc", "lr", "rf", "xgb", "mlp"}

    svc_kernel : str
        If classifier = "svc", name of the kernel to use {"rbf", "poly", "sigmoid"}

    n_splits : int
        Number of splits of SratifiedShuffleSplit used in learning curve

    is_reduce_dim : bool
        Boolean determining if dimensionality reduction method has to be used

    dim_reducer : str
        If is_reduce_dim = True, name of the dimensionality reduction method {"PCA", "LDA"}

    is_feature_sel : bool
        Boolean determining if selection feature by mutual information has to be used

    random_state : int
        The seed of the pseudo random number generator to use

    metric : str
        Metric used to evaluate performance of the classifier

    Returns
    -------
    fpr : False Positive Rate

    tpr : True Positive Rate

    roc_auc : ROC Area Under the Curve

    precisions : array of precisions

    recalls : array of recalls

    AP : average precision based on precisions and recalls arrays

    """

    ## Set parameters of classier to best GridSearch values
    if classifier == "lr":
        pipeline.set_params(lr__C=gs_coarse.best_params_["lr__C"])
    elif classifier == "linear_svc":
        # if is_reduce_dim == True:
        #     if dim_reducer == "PCA":
        #         pipeline = Pipeline([ ("scaler", StandardScaler()),
        #                             ("reduce_dim", PCA(n_components=0.99, random_state=random_state)),
        #                             ("linear_svc", SVC(kernel="linear", C=gs_coarse.best_params_["linear_svc__C"], probability=True, random_state=random_state))
        #                             ])
        #     elif dim_reducer == "LDA":
        #         pipeline = Pipeline([ ("scaler", StandardScaler()),
        #                             ("reduce_dim", LinearDiscriminantAnalysis(n_components=1)),
        #                             ("linear_svc", SVC(kernel="linear", C=gs_coarse.best_params_["linear_svc__C"], probability=True, random_state=random_state))
        #                             ])
        # else:
        #     pipeline = Pipeline([ ("scaler", StandardScaler()),
        #                         ("linear_svc", SVC(kernel="linear", C=gs_coarse.best_params_["linear_svc__C"], probability=True, random_state=random_state))
        #                         ])
        pipeline.set_params(linear_svc__C=gs_coarse.best_params_["linear_svc__C"])
    elif classifier == "svc":
        pipeline.set_params(svc__C=gs_coarse.best_params_["svc__C"])
        pipeline.set_params(svc__gamma=gs_coarse.best_params_["svc__gamma"])
        # pipeline.set_params(svc__probability=True)
        if svc_kernel == "poly":
            pipeline.set_params(svc__degree=gs_coarse.best_params_["svc__degree"])
    elif classifier == "rf":
        pipeline.set_params(rf__n_estimators=gs_coarse.best_params_["rf__n_estimators"])
        pipeline.set_params(rf__bootstrap=gs_coarse.best_params_["rf__bootstrap"])
        pipeline.set_params(rf__min_samples_leaf=gs_coarse.best_params_["rf__min_samples_leaf"])
        # pipeline.set_params(rf__max_features=gs_coarse.best_params_["rf__max_features"])
    elif classifier == "xgb":
        pipeline.set_params(xgb__n_estimators=gs_coarse.best_params_["xgb__n_estimators"])
        pipeline.set_params(xgb__max_depth=gs_coarse.best_params_["xgb__max_depth"])
        pipeline.set_params(xgb__gamma=gs_coarse.best_params_["xgb__gamma"])
        pipeline.set_params(xgb__min_child_weight=gs_coarse.best_params_["xgb__min_child_weight"])
    elif classifier == "mlp":
        pipeline.set_params(mlp__alpha=gs_coarse.best_params_["mlp__alpha"])
        pipeline.set_params(mlp__hidden_layer_sizes=gs_coarse.best_params_["mlp__hidden_layer_sizes"])

    ## Set number of features selected to best GridSearch values
    if is_feature_sel == True:
        if is_reduce_dim == False:
            if X.shape[1] <= 5*X.shape[0]:
                pipeline.set_params(feature_sel__k=gs_coarse.best_params_["feature_sel__k"])

    ## Determine classifier name inside graphic's legend
    if classifier == "svc":
        clf_name = classifier + "_" + svc_kernel
    else:
        clf_name = classifier

    ## Compute learning curve and save it
    title = "Learning Curves: " + clf_name
    # cv = StratifiedKFold(n_splits=8, shuffle=True, random_state=random_state)
    # cv = RepeatedStratifiedKFold(n_splits=10, n_repeats=5, random_state=random_state)
    cv = StratifiedShuffleSplit(n_splits=n_splits, test_size=0.1, random_state=random_state)
    plt, train_sizes, train_scores_mean, train_scores_std,\
    test_scores_mean, test_scores_std = plot_learning_curve(pipeline, title, X, y, ylim=(0.5, 1.03), cv=cv, n_jobs=-1, metric = metric)
    # skplt.estimators.plot_learning_curve(pipeline, X, y, title = "Learning Curves: " + clf_name, cv=LeaveOneOut(),
    #                                     shuffle=True, train_sizes=np.linspace(.1, 1.0, 10), n_jobs=-1)
    save_fig(dir_out, file_name_out + "_LC")
    plt.close('all')

    # ## Do LOOCV to predict probabilities
    # y_pred = cross_val_predict(pipeline, X, y, cv=LeaveOneOut(), method="predict_proba", n_jobs=-1)
    #
    # ## Compute PR and ROC curves and save them plt.savefig(os.path.join(dir_out, "ConfMat" + file_name_out + ".png")
    # skplt.metrics.plot_roc_curve(y, y_pred, title = "ROC curve: " + clf_name)
    # save_fig(dir_out, file_name_out + "_ROC")
    #
    # skplt.metrics.plot_precision_recall_curve(y, y_pred, title = "PR curve: " + clf_name)
    # save_fig(dir_out, file_name_out + "_PR")

    # Do LOOCV
    if hasattr(pipeline.named_steps[classifier], 'decision_function'):
        y_pred = cross_val_predict(pipeline, X, y, cv=LeaveOneOut(), method="decision_function", n_jobs=-1)
    elif hasattr(pipeline.named_steps[classifier], 'predict_proba'):
        y_pred = cross_val_predict(pipeline, X, y, cv=LeaveOneOut(), method="predict_proba", n_jobs=-1)

    ## Compute PR and ROC curves and save them plt.savefig(os.path.join(dir_out, "ConfMat" + file_name_out + ".png")
    if not hasattr(pipeline.named_steps[classifier], 'decision_function') and hasattr(pipeline.named_steps[classifier], 'predict_proba'):
        y_pred = y_pred[:, 1]   ## Take proba of positive class as a score

    # ROC curve
    fpr, tpr, thresholds = roc_curve(y, y_pred, pos_label=1)
    roc_auc = roc_auc_score(y, y_pred)
    plot_roc_curve(fpr, tpr, "blue", label= clf_name + " (AUC = %0.3f)" % roc_auc)
    save_fig(dir_out, file_name_out + "_ROC")
    plt.close('all')

    # PR curve
    precisions, recalls, thresholds = precision_recall_curve(y, y_pred, pos_label=1)
    AP = average_precision_score(y, y_pred)
    plot_precision_vs_recall(precisions, recalls, "blue", label= clf_name + " (AP = %0.3f)" % AP)
    save_fig(dir_out, file_name_out + "_PR")
    plt.close('all')

    # ## Define LOO cross-validation only when no hyperparameter to optimize ##
    # if classifier == "lda" or classifier == "gnb":
    #     if hasattr(pipeline, 'steps'):
    #         if hasattr(pipeline.named_steps[classifier], 'decision_function'):
    #             y_pred = cross_val_predict(pipeline, X, y, cv=LeaveOneOut(), method="decision_function", n_jobs=-1)
    #         elif hasattr(pipeline.named_steps[classifier], 'predict_proba'):
    #             y_pred = cross_val_predict(pipeline, X, y, cv=LeaveOneOut(), method="predict_proba", n_jobs=-1)
    #     else:
    #         if hasattr(pipeline, 'decision_function'):
    #             y_pred = cross_val_predict(pipeline, X, y, cv=LeaveOneOut(), method="decision_function", n_jobs=-1)
    #         elif hasattr(pipeline, 'predict_proba'):
    #             y_pred = cross_val_predict(pipeline, X, y, cv=LeaveOneOut(), method="predict_proba", n_jobs=-1)
    #
    # ## Define LOO nested cross-validation else ##
    # elif classifier == "linear_svc" or classifier == "svc" or classifier == "lr" or classifier == "rf":
    #     if hasattr(pipeline, 'steps'):
    #         if len(pipeline.steps) > 2:
    #             gs_fine = dcv.GridSearchCV(estimator=pipeline,
    #                                         param_grid=param_grid,
    #                                         scoring="accuracy",
    #                                         cv=LeaveOneOut(),
    #                                         n_jobs=1)
    #         else:
    #             gs_fine = GridSearchCV(estimator=pipeline,
    #                                       param_grid=param_grid,
    #                                       scoring="accuracy",ind_svc
    #                                       cv=LeaveOneOut(),
    #                                       n_jobs=1)
    #         if hasattr(pipeline.named_steps[classifier], 'decision_function'):
    #             y_pred = cross_val_predict(gs_fine, X, y, cv=LeaveOneOut(), method="decision_function", n_jobs=-1)
    #         elif hasattr(pipeline.named_steps[classifier], 'predict_proba'):
    #             y_pred = cross_val_predict(gs_fine, X, y, cv=LeaveOneOut(), method="predict_proba", n_jobs=-1)
    #     else:
    #         gs_fine = GridSearchCV(estimator=pipeline,
    #                                   param_grid=param_grid,
    #                                   scoring="accuracy",
    #                                   cv=LeaveOneOut(),
    #                                   n_jobs=1)
    #         if hasattr(pipeline, 'decision_function'):
    #             y_pred = cross_val_predict(gs_fine, X, y, cv=LeaveOneOut(), method="decision_function", n_jobs=-1)
    #         elif hasattr(pipeline, 'predict_proba'):
    #             y_pred = cross_val_predict(gs_fine, X, y, cv=LeaveOneOut(), method="predict_proba", n_jobs=-1)

    return train_sizes, train_scores_mean, train_scores_std,\
            test_scores_mean, test_scores_std, fpr, tpr, roc_auc,\
            precisions, recalls, AP

def run_one_pipeline(X, y, dir_out, file_name_out, classifier, svc_kernel, n_splits, is_reduce_dim, dim_reducer, is_feature_sel, n_feat_selec, random_state, metric):

    ## 2. Create pipeline ##
    pipeline, n_comp_pca, n_comp_lda, cachedir = create_pipeline(X, y, is_reduce_dim = is_reduce_dim, dim_reducer = dim_reducer, is_feature_sel = is_feature_sel, n_feat_selec = n_feat_selec,
                                                        classifier = classifier, svc_kernel = svc_kernel, random_state = random_state)
    print()
    print("Pipeline : ", pipeline)
    print()

    saveObject0 = (pipeline, n_comp_pca, n_comp_lda)
    with open(os.path.join(dir_out, "CreatePipe_" + file_name_out + ".pickle"),"wb") as f:
        pickle.dump(saveObject0, f)

    ## 3. Run coarse LOO GridSearchCV  ##
    param_grid, gs_coarse = run_coarse_gridsearchCV(pipeline, X, y, dir_out = dir_out, file_name_out = file_name_out, is_reduce_dim = is_reduce_dim, dim_reducer = dim_reducer,
                                                    is_feature_sel = is_feature_sel, n_feat_selec = n_feat_selec, n_comp_pca = n_comp_pca, n_comp_lda = n_comp_lda,
                                                    classifier = classifier, svc_kernel = svc_kernel, metric = metric, random_state = random_state)
    print()
    print(param_grid)
    print()

    if param_grid != None and gs_coarse != None:
        saveObject1 = (param_grid, gs_coarse)
        with open(os.path.join(dir_out, "CoarseGS_" + file_name_out + ".pickle"),"wb") as f:
            pickle.dump(saveObject1, f)

    ## 4. Compute graphical metrics: Learning curve, ROC and PR curves ##
    train_sizes, train_scores_mean, train_scores_std,\
    test_scores_mean, test_scores_std, fpr, tpr, roc_auc,\
    precisions, recalls, AP = compute_graphic_metrics(pipeline, X, y, dir_out = dir_out, file_name_out = file_name_out, param_grid = param_grid, gs_coarse=gs_coarse,
                                                    classifier = classifier, svc_kernel = svc_kernel, n_splits = n_splits, is_reduce_dim=is_reduce_dim,
                                                    dim_reducer = dim_reducer, is_feature_sel = is_feature_sel, random_state = random_state, metric = metric)

    saveObject2 = (train_sizes, train_scores_mean, train_scores_std,
            test_scores_mean, test_scores_std, fpr, tpr, roc_auc,
            precisions, recalls, AP)
    with open(os.path.join(dir_out, "GraphMetrics_" + file_name_out + ".pickle"),"wb") as f:
        pickle.dump(saveObject2, f)

    ## 5. Run fine LOO CV (nested according to classifier type)  ##
    pipeline, y_pred, confmat, accuracy, bal_acc, classif_report = run_fine_CV(pipeline, X, y, dir_out = dir_out, file_name_out = file_name_out,
                                                                        name_class0 = "Typical", name_class1 = "Atypical", param_grid = param_grid,
                                                                        gs_coarse = gs_coarse, is_reduce_dim = is_reduce_dim, dim_reducer = dim_reducer,
                                                                        is_feature_sel = is_feature_sel, n_comp_pca = n_comp_pca, n_comp_lda = n_comp_lda,
                                                                        classifier = classifier, svc_kernel = svc_kernel, metric = metric)

    saveObject3 = (pipeline, y_pred, confmat, accuracy, bal_acc, classif_report)
    with open(os.path.join(dir_out, "FineLOOCV_" + file_name_out + ".pickle"),"wb") as f:
        pickle.dump(saveObject3, f)

    # if cachedir != None:
    #     # Delete the temporary cache before exiting
    #     rmtree(cachedir)

def run_one_pipeline_sc_nobias(X_train, y_train, X_test, y_test, dir_out, file_name_out, classifier, svc_kernel, n_splits,
                                is_reduce_dim, dim_reducer, is_feature_sel, n_feat_selec, random_state, metric):

    ## 2. Create pipeline ##
    pipeline, n_comp_pca, n_comp_lda, cachedir = create_pipeline(X_train, y_train, is_reduce_dim = is_reduce_dim, dim_reducer = dim_reducer, is_feature_sel = is_feature_sel, n_feat_selec = n_feat_selec,
                                                        classifier = classifier, svc_kernel = svc_kernel, random_state = random_state)
    print()
    print("Pipeline : ", pipeline)
    print()

    saveObject0 = (pipeline, n_comp_pca, n_comp_lda)
    with open(os.path.join(dir_out, "CreatePipe_" + file_name_out + ".pickle"),"wb") as f:
        pickle.dump(saveObject0, f)

    ## 3. Run coarse LOO GridSearchCV  ##
    param_grid, gs_coarse = run_coarse_gridsearchCV(pipeline, X_train, y_train, dir_out = dir_out, file_name_out = file_name_out, is_reduce_dim = is_reduce_dim, dim_reducer = dim_reducer,
                                                    is_feature_sel = is_feature_sel, n_feat_selec = n_feat_selec, n_comp_pca = n_comp_pca, n_comp_lda = n_comp_lda,
                                                    classifier = classifier, svc_kernel = svc_kernel, metric = metric, random_state = random_state)
    print()
    print(param_grid)
    print()

    if param_grid != None and gs_coarse != None:
        saveObject1 = (param_grid, gs_coarse)
        with open(os.path.join(dir_out, "CoarseGS_" + file_name_out + ".pickle"),"wb") as f:
            pickle.dump(saveObject1, f)

    ## 4. Estimate the performance of the best-selected model  ##
    # param_grid, gs_coarse = None, None
    pipeline, y_pred, confmat, accuracy, bal_acc, classif_report = run_perf_best_estimator(pipeline, X_train, y_train, X_test, y_test, dir_out = dir_out,
                                                                                            file_name_out = file_name_out, name_class0 = "Typical",
                                                                                            name_class1 = "Atypical", param_grid = param_grid, gs_coarse = gs_coarse)

    saveObject2 = (pipeline, y_pred, confmat, accuracy, bal_acc, classif_report)
    with open(os.path.join(dir_out, "PerfBestEstimator_" + file_name_out + ".pickle"),"wb") as f:
        pickle.dump(saveObject2, f)

def bool_parse(test):
    if test.lower() == 'true':
        test = True
    elif test.lower() == 'false':
        test = False
    return test

def main():
    """
    Main function of the classification script

    """

    ## 1. Load .csv file with X features and y labels ndarrays ##
    # dir_out = "/mnt/HDD_2To/COMAJ/Code/MeanPET_ROIs_fwhm0"
    # dir_out = "/mnt/HDD_2To/COMAJ/Code/Vertices_MergeBinROIs_fwhm0"
    # dir_out = "/NAS/tupac/matthieu/ML/code/Python/MeanPET_ROIs_fwhm0"
    # dir_out = "/NAS/tupac/matthieu/ML/code/Python/Vertices_merge_bin/fwhm0"
    # file_name_csv = "PET.M0.MergeClust.Vertices"

    ## Load all dataset for LOOCV
    n_splits = 20
    random_state = 42
    is_avail_csv = sys.argv[1]
    is_avail_csv = bool_parse(is_avail_csv)
    print("is_avail_csv:",is_avail_csv)
    dir_out = sys.argv[2]
    print("dir_out:",dir_out)
    # file_name_csv = sys.argv[3]
    # print("file_name_csv:",file_name_csv)
    # is_reduce_dim = sys.argv[4]
    # is_reduce_dim = bool_parse(is_reduce_dim)
    # print("is_reduce_dim:",is_reduce_dim)
    # n_feat_selec = int(sys.argv[5])
    # print("n_feat_selec:",n_feat_selec)
    # fwhm = sys.argv[3]
    # print("fwhm:",fwhm)

    ## Load train and test dataset for no bias assessment
    file_name_csv_train = sys.argv[3]
    print("file_name_csv_train:",file_name_csv_train)
    file_name_csv_test = sys.argv[4]
    print("file_name_csv_test:",file_name_csv_test)

    if is_avail_csv:
        # ## 1.a Mean PET in significant ROIs extracted from PALM analysis: 82 patients
        # X, y = load_raw_data(is_avail_csv = True, dir_csv = dir_out, file_name_csv = file_name_csv)
        # print()
        # print("X.shape : ", X.shape)
        # print("y.shape : ", y.shape)
        # print()

        ## 1.b Mean PET in significant ROIs extracted from PALM analysis: X_train, y_train & X_test, y_test
        X_train, y_train = load_raw_data(is_avail_csv = True, dir_csv = dir_out, file_name_csv = file_name_csv_train)
        print()
        print("X_train.shape : ", X_train.shape)
        print("y_train.shape : ", y_train.shape)
        print()

        X_test, y_test = load_raw_data(is_avail_csv = True, dir_csv = dir_out, file_name_csv = file_name_csv_test)
        print()
        print("X_test.shape : ", X_test.shape)
        print("y_test.shape : ", y_test.shape)
        print()
    else:
        ## 1.b Load PET surface data with user mask: 82 patients/17 features
        X, y = load_raw_data(is_avail_csv = False, is_surf_data = True, is_surf_binmask_user = False,
                        dir_surf_data_mgh = os.path.join("/NAS/tupac/matthieu/ML/code/Python/Vertices_cortex", "fwhm" + fwhm),
                        file_name_surf_data_mgh = "all.subjects.fwhm" + fwhm + ".PET.MGRousset.gn.A0",
                        nb_class0 = 47, nb_class1 = 35,
                        dir_csv_out = os.path.join("/NAS/tupac/matthieu/ML/code/Python/Vertices_cortex", "fwhm" + fwhm),
                        file_name_csv_out = "PET.M0.MergeClust.Vertices",
                        dir_surf_binmask_user = "/NAS/tupac/matthieu/Correlations/Extraction_cluster_surf/Merge_clusters",
                        file_name_surf_binmask_user = "merge.clusters.cs90.bin",
                        suffix_surf_binmask_user = ".nii.gz")
        print("X.shape : ", X.shape)
        print("y.shape : ", y.shape)
        # print("Features of both methods equal : ", np.array_equal(X, X2))
        # print("Labels of both methods equal : ", np.array_equal(y, y2))

    # n_feat_selec = X.shape[1]
    n_feat_selec = X_train.shape[1]
    for metric in ["accuracy"]:
        dir_out = os.path.join(dir_out, metric)
        for is_reduce_dim in [False]:
            if is_reduce_dim == False :
                for is_feature_sel in [False]:
                        for classifier in ["linear_svc", "svc", "lr", "lda", "gnb", "rf", "mlp", "xgb"]:
                            if classifier == "svc":
                                for svc_kernel in ["rbf", "sigmoid"]:
                                    if is_feature_sel == False:
                                        file_name_out = classifier + "_" + svc_kernel + "_no_rd_" + "no_fs"
                                    else:
                                        file_name_out = classifier + "_" + svc_kernel + "_no_rd_" + "fs_MI_k" + str(n_feat_selec)

                                    # run_one_pipeline(X, y, dir_out, file_name_out, classifier, svc_kernel, n_splits,
                                    #                 is_reduce_dim=False, dim_reducer=None, is_feature_sel=is_feature_sel, n_feat_selec = n_feat_selec,
                                    #                 random_state=random_state, metric = metric)

                                    run_one_pipeline_sc_nobias(X_train, y_train, X_test, y_test, dir_out, file_name_out, classifier, svc_kernel, n_splits,
                                                                is_reduce_dim=False, dim_reducer=None, is_feature_sel=is_feature_sel, n_feat_selec = n_feat_selec,
                                                                random_state=random_state, metric = metric)
                            else:
                                if is_feature_sel == False:
                                    file_name_out = classifier + "_no_rd_" + "no_fs"
                                else:
                                    file_name_out = classifier + "_no_rd_" + "fs_MI_k" + str(n_feat_selec)

                                # run_one_pipeline(X, y, dir_out, file_name_out, classifier, svc_kernel=None, n_splits=n_splits,
                                #                 is_reduce_dim=False, dim_reducer=None, is_feature_sel=is_feature_sel, n_feat_selec = n_feat_selec,
                                #                 random_state=random_state, metric = metric)

                                run_one_pipeline_sc_nobias(X_train, y_train, X_test, y_test, dir_out, file_name_out, classifier, svc_kernel=None, n_splits=n_splits,
                                                            is_reduce_dim=False, dim_reducer=None, is_feature_sel=is_feature_sel, n_feat_selec = n_feat_selec,
                                                            random_state=random_state, metric = metric)
            else:
                for dim_reducer in ["PCA", "LDA"]:
                    for is_feature_sel in [False]:
                            for classifier in ["linear_svc", "svc", "lr", "lda", "gnb", "rf", "mlp", "xgb"]:
                                    if classifier == "svc":
                                        for svc_kernel in ["rbf", "sigmoid"]:
                                            if is_feature_sel == False:
                                                file_name_out = classifier + "_" + svc_kernel + "_rd_" + dim_reducer + "_no_fs"
                                            else:
                                                file_name_out = classifier + "_" + svc_kernel + "_rd_" + dim_reducer + "_fs_MI_k" + str(n_feat_selec)

                                            # run_one_pipeline(X, y, dir_out, file_name_out, classifier, svc_kernel, n_splits,
                                            #                 is_reduce_dim=True, dim_reducer=dim_reducer, is_feature_sel=is_feature_sel, n_feat_selec = n_feat_selec,
                                            #                 random_state=random_state, metric = metric)

                                            run_one_pipeline_sc_nobias(X_train, y_train, X_test, y_test, dir_out, file_name_out, classifier, svc_kernel, n_splits,
                                                            is_reduce_dim=True, dim_reducer=dim_reducer, is_feature_sel=is_feature_sel, n_feat_selec = n_feat_selec,
                                                            random_state=random_state, metric = metric)
                                    else:
                                        if is_feature_sel == False:
                                            file_name_out = classifier + "_rd_" + dim_reducer + "_no_fs"
                                        else:
                                            file_name_out = classifier + "_rd_" + dim_reducer + "_fs_MI_k" + str(n_feat_selec)

                                        # run_one_pipeline(X, y, dir_out, file_name_out, classifier, svc_kernel=None, n_splits=n_splits,
                                        #                 is_reduce_dim=True, dim_reducer=dim_reducer, is_feature_sel=is_feature_sel, n_feat_selec = n_feat_selec,
                                        #                 random_state=random_state, metric = metric)

                                        run_one_pipeline_sc_nobias(X_train, y_train, X_test, y_test, dir_out, file_name_out, classifier, svc_kernel=None, n_splits=n_splits,
                                                        is_reduce_dim=True, dim_reducer=dim_reducer, is_feature_sel=is_feature_sel, n_feat_selec = n_feat_selec,
                                                        random_state=random_state, metric = metric)

    # metric = "accuracy"
    # classifier = "linear_svc"
    # is_reduce_dim = True
    # dim_reducer = "PCA"
    # is_feature_sel = True
    # dir_out = os.path.join(dir_out, metric)
    # file_name_out = classifier + "_rd_PCA" + "fs_MI_k10"
    # svc_kernel = None
    # run_one_pipeline(X, y, dir_out, file_name_out, classifier, svc_kernel, n_splits,
    #                 is_reduce_dim=is_reduce_dim, dim_reducer=dim_reducer, is_feature_sel=is_feature_sel, random_state=random_state, metric = metric)

# with open(os.path.join("/NAS/tupac/matthieu/ML/code/Python/MeanPET_ROIs_fwhm0", "GraphMetrics_" + "lsvc" + ".pickle"), "rb") as f:
#     testout = pickle.load(f)

if __name__ == '__main__':
    # execute only if run as a script
    main()
