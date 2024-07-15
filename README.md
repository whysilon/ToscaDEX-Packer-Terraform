# Automation of Tricentis Tosca DEX Agents

This project serves as a proof-of-concept that it is possible to provision DEX Agents that point to the relevant Tosca server on demand. The project uses Packer to mint the base image of the DEX agents with the correct configurations then subsequently uses Terraform to provision the infrastructure required to run tests.
