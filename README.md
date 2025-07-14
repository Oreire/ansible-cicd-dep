# ansible-cicd-dep
Infrastructure Automation for EC2 Provisioning and Dockerized Application Deployment Using Terraform, Docker-Compose, Ansible, and AWS Dynamic Inventory


- hosts: tag_Name_DevOpsEC2
  become: true

  vars:
    app_dir: /home/ubuntu/myapp
    docker_image_name: webapp:latest
    exposed_port: 80

  tasks:
    - name: Install Docker
      apt:
        name: docker.io
        state: present
      notify: Start Docker

    - name: Create application directory
      file:
        path: "{{ app_dir }}"
        state: directory
        owner: ubuntu
        group: ubuntu
        mode: '0755'

    - name: Copy Dockerfile and app source code
      copy:
        src: ../DOCKE/app/
        dest: "{{ app_dir }}"
        owner: ubuntu
        group: ubuntu
        mode: preserve

    - name: Build Docker image
      command: docker build -t {{ docker_image_name }} .
      args:
        chdir: "{{ app_dir }}"

    - name: Run Docker container
      command: >
        docker run -d --name webapp_container
        -p {{ exposed_port }}:{{ exposed_port }}
        {{ docker_image_name }}

  handlers:
    - name: Start Docker
      service:
        name: docker
        state: started
        enabled: true


