terraform {
  cloud {
    organization = "Monika-Eirian-Lab"
    
    workspaces {
      name = "hal-prod"
    }
  }
}