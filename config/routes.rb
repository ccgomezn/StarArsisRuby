Rails.application.routes.draw do
  get 'index/loadFile'
  get 'index/index'
  get 'index/loadAgrupation'
  get 'index/loadClient'
  get 'index/liquidar'
  get 'index/liquidar_fonografico'
  get 'index/diccionario'
  get 'index/loadSong'
  get 'index/loadAgruptation'
  get 'index/liquidar_general_autor'
  get 'index/liquidar_general_fonografico'

  get 'index/loadFormat'
  get 'index/obrasFono'
  get 'index/crearClient'
  get 'index/crearGrupo'
  get 'index/obrasAutorales'
  get 'index/editarObraAutoral'
  get 'index/editarObraFono'
  get 'index/crearObraFono'
  get 'index/crearObraAutoral'
  get 'index/load_file_by_id'

  match '/executeLoadAgrupation' => 'index#executeLoadAgrupation', via: :post
  match '/executeLoadClient' => 'index#executeLoadClient', via: :post
  match '/executeLoadFile' => 'index#executeLoadFile', via: :post
  match '/executeLoadFileById' => 'index#executeLoadFileById', via: :post
  match '/executeLiquidar' => 'index#executeLiquidar', via: :post
  match '/executeLiquidarFonografico' => 'index#executeLiquidarFonografico', via: :post
  match '/executeLoadDic' => 'index#executeLoadDic', via: :post
  match '/executeLoadFormat' => 'index#executeLoadFormat', via: :post
  match '/executeEditObraAutoral' => 'index#executeEditObraAutoral', via: :post
  match '/executeEditObraFono' => 'index#executeEditObraFono', via: :post
  match '/executeCreateObraFono' => 'index#executeCreateObraFono', via: :post
  match '/executeCreateObraAutoral' => 'index#executeCreateObraAutoral', via: :post
  match '/executeLiquidarGeneralAutoral' => 'index#executeLiquidarGeneralAutoral', via: :post
  match '/executeLiquidarGeneralFonografico' => 'index#executeLiquidarGeneralFonografico', via: :post
  match '/deleteAutoral' => 'index#deleteAutoral', via: :post
  match '/deleteFonografico' => 'index#deleteFonografico', via: :post

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'index#index'
end
