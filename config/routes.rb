Sharedbox::Application.routes.draw do
  resources :folders

  resources :assets

  devise_for :users

  root to: "home#index"
  
  match "assets/get/:id" => "assets#get", :as => "download"
  match "browse/:folder_id" => "home#browse", :as => "browse" 
  #for creating folders insiide another folder  
  match "browse/:folder_id/new_folder" => "folders#new", :as => "new_sub_folder"
  
  #for uploading files to folders  
  match "browse/:folder_id/new_file" => "assets#new", :as => "new_sub_file"
  
  match "browse/:folder_id/rename" => "folders#edit", :as => "rename_folder"
  match "home/share" => "home#share"
end
