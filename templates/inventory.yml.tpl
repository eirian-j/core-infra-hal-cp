all:
  hosts:
    ${instance_name}:
      ansible_host: ${public_ip}
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
      ansible_python_interpreter: /usr/bin/python3
      
  vars:
    project_name: ${project_name}
    environment: ${environment}
    domain: ${domain}
    private_ip: ${private_ip}
    
  children:
    control_plane:
      hosts:
        ${instance_name}: