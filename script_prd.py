#!/usr/bin/python3
import os

workdir = '/home/gitlab-runner/builds/aJrSxneHG/0/test4sw/poc/'

with open(f'{workdir}stg_data.txt', 'r') as file:
	contents = file.read().rstrip().split('\n')

def execute_terraform_command(root_module_path):
    command = f"cd {root_module_path} && terraform apply --auto-approve"
    os.system(command)
    print(f"Excuting Terraform Command In: {root_module_path}")

temp_path = []

for i in contents:
	a = i.find('ment')
	b = i.find('/', a+5)
	temp_path.append(i[:b])

final_path = set(temp_path)

print(final_path)

for a in final_path:
	execute_terraform_command(workdir+a)