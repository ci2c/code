import numpy as np
import io
from termcolor import colored, cprint
import glob
import os
import shutil
import xml.etree.ElementTree as ET

from CommonUtils import *

def create_SWRun_xml(xmlfilename, inDataFiles, parameterDictionary, outDir):
	root = ET.Element('sample')
	output_dir = ET.SubElement(root, 'output_dir')
	output_dir.text = "\n" + outDir + "\n"
	number_of_particles = ET.SubElement(root, 'number_of_particles')
	number_of_particles.text = "\n" + str(parameterDictionary['number_of_particles']) + "\n"
	use_normals = ET.SubElement(root, 'use_normals')
	use_normals.text = "\n" + str(parameterDictionary['use_normals']) + "\n"
	if parameterDictionary['use_normals'] == 0:
		attribute_scales = ET.SubElement(root, 'attribute_scales')
		attribute_scales.text = "\n 1.0 \n 1.0 \n 1.0\n"
	else:    
		attribute_scales = ET.SubElement(root, 'attribute_scales')
		attribute_scales.text = "\n 1.0 \n 1.0 \n 1.0 \n 1.0 \n  1.0 \n  1.0 \n"
	checkpointing_interval = ET.SubElement(root, 'checkpointing_interval')
	checkpointing_interval.text = "\n" + str(parameterDictionary['checkpointing_interval']) + "\n"
	keep_checkpoints = ET.SubElement(root, 'keep_checkpoints')
	keep_checkpoints.text = "\n" + str(parameterDictionary['keep_checkpoints']) + "\n"
	iterations_per_split = ET.SubElement(root, 'iterations_per_split')
	iterations_per_split.text = "\n" + str(parameterDictionary['iterations_per_split']) + "\n"
	optimization_iterations = ET.SubElement(root, 'optimization_iterations')
	optimization_iterations.text = "\n" + str(parameterDictionary['optimization_iterations']) + "\n"
	starting_regularization = ET.SubElement(root, 'starting_regularization')
	starting_regularization.text = "\n" + str(parameterDictionary['starting_regularization']) + "\n"
	ending_regularization = ET.SubElement(root, 'ending_regularization')
	ending_regularization.text = "\n" + str(parameterDictionary['ending_regularization']) + "\n"
	recompute_regularization_interval = ET.SubElement(root, 'recompute_regularization_interval')
	recompute_regularization_interval.text = "\n" + str(parameterDictionary['recompute_regularization_interval']) + "\n"
	domains_per_shape = ET.SubElement(root, 'domains_per_shape')
	domains_per_shape.text = "\n" + str(parameterDictionary['domains_per_shape']) + "\n"
	relative_weighting = ET.SubElement(root, 'relative_weighting')
	relative_weighting.text = "\n" + str(parameterDictionary['relative_weighting']) + "\n"
	initial_relative_weighting = ET.SubElement(root, 'initial_relative_weighting')
	initial_relative_weighting.text = "\n" + str(parameterDictionary['initial_relative_weighting']) + "\n"
	procrustes_interval = ET.SubElement(root, 'procrustes_interval')
	procrustes_interval.text = "\n" + str(parameterDictionary['procrustes_interval']) + "\n"
	procrustes_scaling = ET.SubElement(root, 'procrustes_scaling')
	procrustes_scaling.text = "\n" + str(parameterDictionary['procrustes_scaling']) + "\n"
	save_init_splits = ET.SubElement(root, 'save_init_splits')
	save_init_splits.text = "\n" + str(parameterDictionary['save_init_splits']) + "\n"
	debug_projection = ET.SubElement(root, 'debug_projection')
	debug_projection.text = "\n" + str(parameterDictionary['debug_projection']) + "\n"
	mesh_based_attributes = ET.SubElement(root, 'mesh_based_attributes')
	mesh_based_attributes.text = "\n" + str(parameterDictionary['mesh_based_attributes']) + "\n"
	verbosity = ET.SubElement(root, 'verbosity')
	verbosity.text = "\n" + str(parameterDictionary['verbosity']) + "\n"
	inputs = ET.SubElement(root, 'inputs')
	inputs.text = "\n"
	for i in range(len(inDataFiles)):
		t1 = inputs.text
		t1 = t1 + inDataFiles[i] + '\n'
		inputs.text = t1

	data = ET.tostring(root, encoding='unicode')
	file = open(xmlfilename, "w+")
	file.write(data)

def create_SWRun_multi_xml(xmlfilename, inDataFiles, parameterDictionary, outDir, curFactor, lastPointFiles):
	root = ET.Element('sample')
	output_dir = ET.SubElement(root, 'output_dir')
	output_dir.text = "\n" + outDir + "\n"
	startFactor = int(parameterDictionary['starting_particles'])
	startFactor = int(np.floor(np.log2(startFactor)))
	N = int(2**(startFactor + curFactor))
	number_of_particles = ET.SubElement(root, 'number_of_particles')
	number_of_particles.text = "\n" + str(N) + "\n"
	use_normals = ET.SubElement(root, 'use_normals')
	use_normals.text = "\n" + str(parameterDictionary['use_normals']) + "\n"
	if parameterDictionary['use_normals'] == 0:
		attribute_scales = ET.SubElement(root, 'attribute_scales')
		attribute_scales.text = "\n 1.0 \n 1.0 \n 1.0\n"
	else:    
		attribute_scales = ET.SubElement(root, 'attribute_scales')
		attribute_scales.text = "\n 1.0 \n 1.0 \n 1.0 \n 1.0 \n  1.0 \n  1.0 \n"
	checkpointing_interval = ET.SubElement(root, 'checkpointing_interval')
	checkpointing_interval.text = "\n" + str(parameterDictionary['checkpointing_interval']) + "\n"
	keep_checkpoints = ET.SubElement(root, 'keep_checkpoints')
	keep_checkpoints.text = "\n" + str(parameterDictionary['keep_checkpoints']) + "\n"
	iterations_per_split = ET.SubElement(root, 'iterations_per_split')
	iterations_per_split.text = "\n" + str(parameterDictionary['iterations_per_split']) + "\n"
	optimization_iterations = ET.SubElement(root, 'optimization_iterations')
	optimization_iterations.text = "\n" + str(parameterDictionary['optimization_iterations']) + "\n"
	starting_regularization = ET.SubElement(root, 'starting_regularization')
	starting_regularization.text = "\n" + str(parameterDictionary['starting_regularization']) + "\n"
	ending_regularization = ET.SubElement(root, 'ending_regularization')
	ending_regularization.text = "\n" + str(parameterDictionary['ending_regularization']) + "\n"
	recompute_regularization_interval = ET.SubElement(root, 'recompute_regularization_interval')
	recompute_regularization_interval.text = "\n" + str(parameterDictionary['recompute_regularization_interval']) + "\n"
	domains_per_shape = ET.SubElement(root, 'domains_per_shape')
	domains_per_shape.text = "\n" + str(parameterDictionary['domains_per_shape']) + "\n"
	relative_weighting = ET.SubElement(root, 'relative_weighting')
	relative_weighting.text = "\n" + str(parameterDictionary['relative_weighting']) + "\n"
	initial_relative_weighting = ET.SubElement(root, 'initial_relative_weighting')
	initial_relative_weighting.text = "\n" + str(parameterDictionary['initial_relative_weighting']) + "\n"
	procrustes_interval = ET.SubElement(root, 'procrustes_interval')
	procrustes_interval.text = "\n" + str(parameterDictionary['procrustes_interval']) + "\n"
	procrustes_scaling = ET.SubElement(root, 'procrustes_scaling')
	procrustes_scaling.text = "\n" + str(parameterDictionary['procrustes_scaling']) + "\n"
	save_init_splits = ET.SubElement(root, 'save_init_splits')
	save_init_splits.text = "\n" + str(parameterDictionary['save_init_splits']) + "\n"
	debug_projection = ET.SubElement(root, 'debug_projection')
	debug_projection.text = "\n" + str(parameterDictionary['debug_projection']) + "\n"
	mesh_based_attributes = ET.SubElement(root, 'mesh_based_attributes')
	mesh_based_attributes.text = "\n" + str(parameterDictionary['mesh_based_attributes']) + "\n"
	verbosity = ET.SubElement(root, 'verbosity')
	verbosity.text = "\n" + str(parameterDictionary['verbosity']) + "\n"
	inputs = ET.SubElement(root, 'inputs')
	inputs.text = "\n"
	for i in range(len(inDataFiles)):
		t1 = inputs.text
		t1 = t1 + inDataFiles[i] + '\n'
		inputs.text = t1

	if curFactor != 0:
		# add in the pointfiles
		init_stats = ET.SubElement(root, 'use_shape_statistics_in_init')
		init_stats.text = "\n" + str(1.0) + "\n"
		points = ET.SubElement(root, 'point_files')
		points.text = "\n"
		for i in range(len(lastPointFiles)):
			t1 = points.text
			t1 = t1 + lastPointFiles[i] + '\n'
			points.text = t1
	if curFactor == 0:
		init_stats = ET.SubElement(root, 'use_shape_statistics_in_init')
		init_stats.text = "\n" + str(0.0) + "\n"

	data = ET.tostring(root, encoding='unicode')
	file = open(xmlfilename, "w+")
	file.write(data)

def runShapeWorksOptimize_Basic(parentDir, inDataFiles, parameterDictionary):
	numP = parameterDictionary['number_of_particles']
	outDir = os.path.join(parentDir , str(numP) + '/')
	if not os.path.exists(outDir):
		os.makedirs(outDir)

	parameterFile = parentDir + "correspondence_" + str(numP) + '.xml'
	create_SWRun_xml(parameterFile, inDataFiles, parameterDictionary, outDir)
	create_cpp_xml(parameterFile, parameterFile)
	print(parameterFile)
	execCommand = "ShapeWorksRun5.0 " + parameterFile
	os.system(execCommand)
	outPointsWorld = []
	outPointsLocal = []
	for i in range(len(inDataFiles)):
		inname = inDataFiles[i]
		spt = inname.rsplit('/', 1)
		inpath = spt[0] + '/'
		outname = inname.replace(inpath, outDir)
		wrdname = outname.replace('.nrrd', '_world.particles')
		lclname = outname.replace('.nrrd', '_local.particles')
		outPointsWorld.append(wrdname)
		outPointsLocal.append(lclname)
	return [outPointsLocal, outPointsWorld]

def runShapeWorksOptimize_MultiScale(parentDir, inDataFiles, parameterDictionary):
	numP_init = parameterDictionary['starting_particles']
	num_levels = parameterDictionary['number_of_levels']	
	
	startFactor = int(np.floor(np.log2(numP_init)))
	print("Starting Factor", startFactor)

	for i in range(num_levels):
		outDir = os.path.join(parentDir ,  str(2**(startFactor + i)) + '/')
		if not os.path.exists(outDir):
			os.makedirs(outDir)
		prevOutDir = os.path.join(parentDir ,  str(2**(startFactor + i - 1)) + '/')
		parameterFile = parentDir + "correspondence_" + str(2**(startFactor + i)) + '.xml'
		inparts = []
		for j in range(len(inDataFiles)):
			inname = inDataFiles[j]
			spt = inname.rsplit('/', 1)
			inpath = spt[0] + '/'
			outname = inname.replace(inpath, prevOutDir)
			lclname = outname.replace('.nrrd', '_local.particles')
			inparts.append(lclname)
		create_SWRun_multi_xml(parameterFile, inDataFiles, parameterDictionary, outDir, i, inparts)
		create_cpp_xml(parameterFile, parameterFile)
		print(parameterFile)
		execCommand = "ShapeWorksRun5.0 " + parameterFile
		print(execCommand)
		os.system(execCommand)

	outPointsWorld = []
	outPointsLocal = []
	for i in range(len(inDataFiles)):
		inname = inDataFiles[i]
		spt = inname.rsplit('/', 1)
		inpath = spt[0] + '/'
		outname = inname.replace(inpath, outDir)
		wrdname = outname.replace('.nrrd', '_world.particles')
		lclname = outname.replace('.nrrd', '_local.particles')
		outPointsWorld.append(wrdname)
		outPointsLocal.append(lclname)
	return [outPointsLocal, outPointsWorld]
