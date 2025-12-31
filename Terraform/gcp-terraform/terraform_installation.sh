###########################################################################
echo "Update system packages"
sudo apt update && sudo apt install -y gnupg software-properties-common curl

###########################################################################
echo "Add HashiCorp GPG key"
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

###########################################################################
echo "Add HashiCorp repository"
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

###########################################################################
echo "Install Terraform in Codespace"
sudo apt update
sudo apt install terraform -y

###########################################################################
echo "Verify installation"
terraform version
