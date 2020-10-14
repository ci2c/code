function output = bash(command)

[~, output] = system(['. ~/.bashrc; ' command]);