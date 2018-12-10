
class IndexController < ApplicationController
  skip_before_action :verify_authenticity_token  
  def index
  end

  def executeLoadAgrupation
  	agrupacion = Agrupacion.create(Id_grupo: params[:id_agrupacion],Nombre_grupo: params[:nombre_agrupacion], Id_genero: params[:id_genero], Id_tipo_banda: params[:id_tipo_agrupacion])
    integrantes = params[:integrantes]

    integrantes.each do |id|
      grupo_contratante = GrupoContratante.create(Id_grupo: params[:id_agrupacion], Id_contratante: id)
    end
  end

  def executeLoadClient
  	cliente = Contratante.create(Id_contratante: params[:id_cliente],Nombre_contratante: params[:nombre_cliente],Correo_contratante: params[:email], Direccion_contratante: params[:direccion],Ciudad_contratante: params[:ciudad])
    tipos_contratante = params[:tipo_usuario]

    tipos_contratante.each do |id|
      cliente_tipo_contratante = ContratanteTipoContratante.create(id_Contratante: params[:id_cliente], id_Tipo_contratante: id)
    end
  end

  def executeLoadFile
  	id_socio = params[:socio]
  	data_doc = params[:document]
    formato = FormatoDocumento.find(id_socio)
    for i in 0..(formato.fila_inicial-1)
      data_doc.delete(0)
    end

    data_doc.each do |row|
      id_obra = Obra.find_by(nombre_obra: row[formato.nombre_obra])
      if(id_obra != nil)
        id_obra = id_obra.Id_obra
        precio = row[formato.precio]
        if(formato.tipo_aparicion == nil)
          tipo_aparicion = nil
        else
          tipo_aparicion = row[formato.tipo_aparicion]
        end
        if(formato.duracion == nil)
          duracion = nil
        else
          duracion = row[formato.duracion]
        end
        if(formato.cantidad == nil)
          cantidad = nil
        else
          cantidad = row[formato.cantidad]
        end
        if(formato.fecha == nil)
          fecha = nil
        else
          fecha = row[formato.fecha]
        end
        if(formato.territorio == nil)
          territorio = nil
        else
          territorio = row[formato.territorio]
        end
        if(formato.medio_aparicion == nil)
          medio_aparicion = nil
        else
          medio_aparicion = row[formato.medio_aparicion]
        end

        aparicion = Aparicion.create(Id_obra: id_obra, Id_reporte: 12, Id_socio: id_socio, Id_Tipo_aparicion: tipo_aparicion, Duracion: duracion, Cantidad: cantidad, Precio: precio, Fecha: params[:fecha], Territorio: territorio, Id_medio_aparicion: medio_aparicion, Fonograma: params[:fonograma])
      end
    end

  end


  def executeLiquidar
    fecha_init = params[:initDate]
    fecha_fin = params[:dateEnd]
    tipo = params[:tipo]

    workbook = RubyXL::Workbook.new
    worksheet = workbook.add_worksheet('liquidacion')
    if(tipo == 0)
      headers = ['obra', 'territorio','fonograma','porcentaje_subeditor', 'porcentaje_autor', 'porcentaje_editora', 'porcentaje_autor_internacional', 'porcentaje_editora_internacional']
      col = 0

      headers.each do |hd|
        worksheet.add_cell(0,col,hd)
        col += 1
      end

      row = 1
      Aparicion.where("Fecha > ? AND Fecha < ?", fecha_init,fecha_fin).each do |aparicion|
        id_obra = aparicion.Id_obra
        price = aparicion.Precio

        obra = Obra.find(id_obra)
        data = [obra.Nombre_obra, aparicion.Territorio, aparicion.Fonograma, Float(obra.Porcentaje_subeditor)/100*price,Float(obra.Porcentaje_autor)/100*price, Float(obra.Porcentaje_editora)/100*price, Float(obra.Porcentaje_autor_int)/100*price, Float(obra.Porcentaje_editora_int)/100*price  ]

        col = 0
        data.each do |cl|
          worksheet.add_cell(row,col,cl)
          col += 1
        end
        row += 1
      end

      workbook.write("liquidacion.xlsx")
    elsif(tipo == 1)

    end

    
  end


end
