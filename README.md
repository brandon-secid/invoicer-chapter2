Modified Securing DevOps
==========================

# :triangular_flag_on_post: *Do Not Run this in a non-sandbox Environment* :triangular_flag_on_post: 


This repo is a learning repo, pulled from the [Securing DevOps Book](https://amzn.to/3t7dJdd). I have modified this step to run completely within AWS. 

This should only be ran in a ACG Sandbox, do not run any of this in prodcution accounts :) 

Setup
-----------------

The first thing to do is clone this repo. 

Next install and hook [direnv](https://direnv.net/docs/installation.html) in your terminal. 

In the Terraform folder, create a `.envrc` file in the Terraform directory. Include the following variables: 
```
#Configure AWS profile and Github Token
export TF_VAR_DOCKER_USER=yourdockeruser
export TF_VAR_DOCKER_KEY=yourdockerapikey
export TF_VAR_GITHUB_TOKEN=yourpattoken
export TF_VAR_DB_PASS=somesecretpasstobeyourdatabasepassword
export AWS_PROFILE=yourawsprofile
export AWS_REGION=us-east-1
```
Where TF_VAR_GITHUB_TOKEN is a [Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token). AWS Profile can be the name of your choice, see below for more information regarding this variable. Same goes for the AWS region. Finally, include your docker user name and API token to be able to push to Docker Hub.

I like to use ACloudGuru's sandbox for this build, as it is used for learning purposes. Create a [profile](https://docs.aws.amazon.com/sdk-for-php/v3/developer-guide/guide_credentials_profiles.html) called whatever you want to call it, add fresh creds each time you kick off the sandbox.  Whatever you name it, it should be exported as the profile to use in the .envrc config above.

