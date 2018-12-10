Rails.application.routes.draw do
  get 'index/loadFile'
  get 'index/index'
  get 'index/loadAgrupation'
  get 'index/loadClient'
  get 'index/liquidar'


  match '/executeLoadAgrupation' => 'index#executeLoadAgrupation', via: :post
  match '/executeLoadClient' => 'index#executeLoadClient', via: :post
  match '/executeLoadFile' => 'index#executeLoadFile', via: :post
  match '/executeLiquidar' => 'index#executeLiquidar', via: :post
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'index#index'
end
