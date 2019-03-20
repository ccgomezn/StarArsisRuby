
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
  def executeLoadFileById
      	data_doc = params[:document]
    data_no_subida = []
    for i in 0..(params[:fila_inicio].to_i-1)
      data_doc.delete(0)
    end
    data_doc.each do |row|
      if(row[params[:col_id].to_i] !=  nil)
        if(params[:tipo_aparicion].to_i === 1)
          id_obra = Obra.find_by(Id_obra: row[params[:col_id].to_i])
        else
          id_obra = ObraAutoral.find_by(Id_obra: row[params[:col_id].to_i])
        end
        

        if(id_obra != nil)
          id_obra = id_obra.Id_obra
          precio = row[params[:col_valor].to_i]
          
          Time.zone = 'Bogota'
          aparicion = Aparicion.create(Id_obra: id_obra, Id_reporte: reporte.Id_reporte, Id_socio: id_socio, Duracion: duracion, Cantidad: cantidad, Precio: precio, Fecha: params[:fecha], Territorio: territorio, Id_medio_aparicion: medio_aparicion)
        else
          data_no_subida.push(row[params[:col_id].to_i]);
        end
      end
      end
        render json: {"no_subido": data_no_subida}
  end
  def executeLoadFile
  	id_socio = params[:socio]
  	data_doc = params[:document]
    
    nombre_reporte = params[:nombre] + " ( " + params[:fecha] + " ) "
    reporte = Reporte.create(Id_reporte: nil,Doc_reporte:params[:document_blob], Estado_pago: 0, Fecha: params[:fecha], Id_socio: id_socio, Id_tipo_aparicion: params[:tipo_aparicion], Nombre_reporte: nombre_reporte,Comentario: params[:comentario])
    reporte = Reporte.last
          data_no_subida = []

    if(params[:socio].to_i === 6)
      i = 0
      puts('longitud ' + data_doc.length.to_s)
      data_doc.each do |line|
        if(i == 0)
          i += 1

          next
        end
        if(line[47..79] != nil)
          nombre_obra = line[47..79].strip
          precio = line[286..295].to_i
          if(params[:tipo_aparicion].to_i === 1)
            id_obra = Obra.find_by(nombre_obra: nombre_obra)
            if(id_obra == nil)
              wordDic = Diccionario.find_by(entrada: nombre_obra)
              if(wordDic != nil)
                id_obra = Obra.find_by(nombre_obra: wordDic)
              end
            end
          else
            id_obra = ObraAutoral.find_by(nombre_obra: nombre_obra)
            if(id_obra == nil)
              wordDic = Diccionario.find_by(entrada: nombre_obra)
              if(wordDic != nil)
                id_obra = ObraAutoral.find_by(nombre_obra: wordDic)
              end
            end
          end

          if(id_obra != nil)
            id_obra = id_obra.Id_obra

            Time.zone = 'Bogota'
            aparicion = Aparicion.create(Id_obra: id_obra, Id_reporte: reporte.Id_reporte, Id_socio: id_socio, Duracion: nil, Cantidad: nil, Precio: precio, Fecha: params[:fecha], Territorio: nil, Id_medio_aparicion: nil)
          else
            data_no_subida.push(nombre_obra)
          end
        end
      end

      
    else
      formato = FormatoDocumento.find(id_socio)
      data_no_subida = []
      for i in 0..(formato.fila_inicial-1)
        data_doc.delete(0)
      end
      data_doc.each do |row|
        if(params[:tipo_aparicion].to_i === 1)
          id_obra = Obra.find_by(nombre_obra: row[formato.nombre_obra])
          if(id_obra == nil)
            wordDic = Diccionario.find_by(entrada: row[formato.nombre_obra])
            if(wordDic != nil)
              id_obra = Obra.find_by(nombre_obra: wordDic)
            end
          end
        else
          id_obra = ObraAutoral.find_by(nombre_obra: row[formato.nombre_obra])
          if(id_obra == nil)
            wordDic = Diccionario.find_by(entrada: row[formato.nombre_obra])
            if(wordDic != nil)
              id_obra = ObraAutoral.find_by(nombre_obra: wordDic)
            end
          end
        end
        

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
          Time.zone = 'Bogota'
          aparicion = Aparicion.create(Id_obra: id_obra, Id_reporte: reporte.Id_reporte, Id_socio: id_socio, Duracion: duracion, Cantidad: cantidad, Precio: precio, Fecha: params[:fecha], Territorio: territorio, Id_medio_aparicion: medio_aparicion)
        else
          data_no_subida.push(row[formato.nombre_obra]);
        end

      end
  
    end
    render json: {"no_subido": data_no_subida}

  end

  def executeLoadDic
    entrada = params[:entrada]
    salida = params[:salida]
    Diccionario.create(Entrada: entrada, Salida: salida)
  end
  def executeLiquidar
    
    workbook = RubyXL::Workbook.new
    worksheet = workbook.add_worksheet('liquidacion')
      headers = ['id obra', 'obra', 'id autor','nombre autor', 'grupo interprete', 'territorio', 'porcentaje_autor', 'porcentaje_editora','valor reportado', 'valor editora', 'valor autor' , 'catalogo']
      col = 0

      headers.each do |hd|
        worksheet.add_cell(0,col,hd)
        col += 1
      end
      
      row = 1
      for i in 0..(params[:n_reports].to_i-1)
        id_reporte = params[:"report_#{i}"]
        iva_incluido = params[:"iva_incluido#{i}"]
        mas_iva = params[:"mas_iva#{i}"]
        Aparicion.where("Id_reporte = ?", id_reporte).each do |aparicion|
          id_obra = aparicion.Id_obra
          price = aparicion.Precio
          price = price/(1+(iva_incluido.to_f)/100.0)
          price = price - price*(mas_iva.to_f)/100.0
          obra = ObraAutoral.where("Id_obra=? AND Catalogo=?", id_obra, params[:catalogo])[0]
          if(obra != nil)
            if(aparicion.Territorio == 'Colombia' || aparicion.Territorio == nil)
              porcentaje_autor = obra.Porcentaje_colombia
              porcentaje_editora = obra.Porcentaje_editora_colombia
            else
              porcentaje_autor = obra.Porcentaje_internacional
              porcentaje_editora = obra.Porcentaje_editora_internacional
              
            end
            if(Contratante.find_by(Id_contratante: obra.Autor_id) != nil)
                nombre_contratante = Contratante.find_by(Id_contratante: obra.Autor_id).Nombre_contratante
                
            else
              nombre_contratante = 'Autor no reconocido'
            end
                price_editora = porcentaje_editora*price
                price_editora = price_editora - (price_editora*params[:descuento].to_f/100.0)
                price_autor = porcentaje_autor*price
                price_autor = price_autor - (price_autor*params[:descuento].to_f/100.0)
                
                data = [id_obra, obra.Nombre_obra,obra.Autor_id ,nombre_contratante, Agrupacion.find(obra.Grupo).Nombre_grupo, aparicion.Territorio,porcentaje_autor,porcentaje_editora, price, price_editora, price_autor, obra.Catalogo ]
                

                col = 0
                data.each do |cl|
                  worksheet.add_cell(row,col,cl)
                  col += 1
                end
            row += 1
          end
          
        end
      end

      send_data workbook.stream.string, filename: "liquidacionAutoral.xlsx",
                                    disposition: 'attachment'
      
    end


    def executeLiquidarGeneralAutoral
    
    workbook = RubyXL::Workbook.new
    worksheet = workbook.add_worksheet('liquidacion')
      headers = ['id obra', 'obra', 'id autor','nombre autor', 'grupo interprete', 'territorio', 'porcentaje_autor', 'porcentaje_editora','valor reportado', 'valor editora', 'valor autor' , 'catalogo']
      col = 0

      headers.each do |hd|
        worksheet.add_cell(0,col,hd)
        col += 1
      end
      usuario = params[:id_usuario]
      fecha_i = params[:fecha_inicio]
      fecha_f = params[:fecha_fin]
      row = 1
        Aparicion.joins(" INNER JOIN Obra_autoral ON Aparicion.Id_obra = Obra_autoral.Id_obra").where("Obra_autoral.Autor_id = ? AND Aparicion.fecha >= ? AND Aparicion.fecha <= ?", usuario, fecha_i, fecha_f).each do |aparicion|
          id_obra = aparicion.Id_obra
          price = aparicion.Precio/1.19
          obra = ObraAutoral.where("Id_obra=? AND Catalogo=?", id_obra)[0]
          if(obra != nil)
            if(aparicion.Territorio == 'Colombia' || aparicion.Territorio == nil)
              porcentaje_autor = obra.Porcentaje_colombia
              porcentaje_editora = obra.Porcentaje_editora_colombia
            else
              porcentaje_autor = obra.Porcentaje_internacional
              porcentaje_editora = obra.Porcentaje_editora_internacional
              
            end
            if(Contratante.find_by(Id_contratante: obra.Autor_id) != nil)
                nombre_contratante = Contratante.find_by(Id_contratante: obra.Autor_id).Nombre_contratante
                
            else
              nombre_contratante = 'Autor no reconocido'
            end
                price_editora = porcentaje_editora*price
                price_editora = price_editora - (price_editora*params[:descuento].to_f/100.0)
                price_autor = porcentaje_autor*price
                price_autor = price_autor - (price_autor*params[:descuento].to_f/100.0)
                
                data = [id_obra, obra.Nombre_obra,obra.Autor_id ,nombre_contratante, Agrupacion.find(obra.Grupo).Nombre_grupo, aparicion.Territorio,porcentaje_autor,porcentaje_editora, price, price_editora, price_autor, obra.Catalogo ]
                

                col = 0
                data.each do |cl|
                  worksheet.add_cell(row,col,cl)
                  col += 1
                end
            row += 1
          end
          
        end

      send_data workbook.stream.string, filename: "liquidacionAutoral.xlsx",
                                    disposition: 'attachment'
      
    end

    def executeLoadFormat
      organizacion = params[:organizacion]
      nombre = params[:nombre]
      tipo = params[:tipo]
      duracion = params[:duracion]
      cantidad = params[:cantidad]
      precio = params[:precio]
      fecha = params[:fecha]
      territorio = params[:territorio]
      medio = params[:medio]
      fila = params[:fila]
      nombre_formato = params[:nombre_formato]
      
      FormatoDocumento.create(id_socio: organizacion, nombre_obra: nombre, tipo_aparicion: tipo, duracion: duracion, cantidad: cantidad, precio: precio, fecha: fecha, territorio: territorio, medio_aparicion: medio, fila_inicial: fila, nombre_formato: nombre_formato)
      redirect_to "/index/loadFormat"
    end

    def executeEditObraFono
            Obra.update(params[:id], Nombre_obra: params[:nombre], Id_grupo: params[:grupo], Porcentaje_subeditor_fon: params[:porcentaje_subeditor], Porcentaje_editora_fon: params[:porcentaje_editor], Porcentaje_interprete_fon: params[:porcentaje_interprete], Editora: params[:porcentaje_editora_internacional], Editora: params[:catalogo])
      redirect_to "/index/obrasFono"

    end

    def executeCreateObraFono
            Obra.create(Id_obra: params[:id], Nombre_obra: params[:nombre], Id_grupo: params[:grupo], Porcentaje_subeditor_fon: params[:porcentaje_subeditor], Porcentaje_editora_fon: params[:porcentaje_editor], Porcentaje_interprete_fon: params[:porcentaje_interprete], Editora: params[:porcentaje_editora_internacional], Editora: params[:catalogo])
          redirect_to "/index/obrasFono"

          end
    
    def executeCreateObraAutoral
      ObraAutoral.create(Nombre_obra: params[:nombre], Autor_id: params[:autor], Grupo: params[:grupo], Porcentaje_colombia: params[:porcentaje_colombia], Porcentaje_internacional: params[:porcentaje_internacional], Porcentaje_editora_colombia: params[:porcentaje_editora_colombia], Porcentaje_editora_internacional: params[:porcentaje_editora_internacional], Catalogo: params[:catalogo])
      redirect_to "/index/obrasAutorales"
    end
    def executeEditObraAutoral
      ObraAutoral.update(params[:id], Nombre_obra: params[:nombre], Autor_id: params[:autor], Grupo: params[:grupo], Porcentaje_colombia: params[:porcentaje_colombia], Porcentaje_internacional: params[:porcentaje_internacional], Porcentaje_editora_colombia: params[:porcentaje_editora_colombia], Porcentaje_editora_internacional: params[:porcentaje_editora_internacional], Catalogo: params[:catalogo])
      redirect_to "/index/obrasAutorales"
    end

    def editarObraAutoral
      @obra_autoral = ObraAutoral.find(params[:id])
    end
    def editarObraFono
      @obra_fono = Obra.find(params[:id])
    end

    def obrasFono
      @obras_fono = Array.new()
      Obra.find_each do |obra|
        @obras_fono.push(obra)
      end
    end

    def obrasAutorales
      @obras_autorales = Array.new()
      ObraAutoral.find_each do |obra|
        @obras_autorales.push(obra)
      end
    end
    def deleteAutoral
      Reporte.find(params[:id]).destroy
      redirect_to "/index/liquidar"

    end
    def deleteFonografico
      Reporte.find(params[:id]).destroy
      redirect_to "/index/liquidar_fonografico"

    end
    def executeLiquidarFonografico
    
      workbook = RubyXL::Workbook.new
      worksheet = workbook.add_worksheet('liquidacion')
        headers = ['id obra', 'obra', 'grupo interprete', 'territorio', 'porcentaje interprete', 'porcentaje editora', 'porcentaje sub editora','valor reportado', 'valor sub editora', 'valor editora', 'valor interprete' , 'editora']
        col = 0
  
        headers.each do |hd|
          worksheet.add_cell(0,col,hd)
          col += 1
        end
  
        row = 1
        for i in 0..(params[:n_reports].to_i-1)
            id_reporte = params[:"report_#{i}"]
            iva_incluido = params[:"iva_incluido#{i}"]
            mas_iva = params[:"mas_iva#{i}"]          
            Aparicion.where("Id_reporte = ?", id_reporte).each do |aparicion|
            id_obra = aparicion.Id_obra
            price = aparicion.Precio
            price = price/(1+(iva_incluido.to_f)/100.0)
            price = price - price*(mas_iva.to_f)/100.0
            obra = Obra.where("Id_obra=? AND Editora=?", id_obra, params[:catalogo])[0]
            if(obra != nil)
              porcentaje_interprete = obra.Porcentaje_interprete_fon
              porcentaje_editora = obra.Porcentaje_editora_fon
              porcentaje_subeditora = obra.Porcentaje_subeditor_fon
              valor_subeditor = price*porcentaje_subeditora;
              valor_subeditor -= valor_subeditor*params[:descuento].to_f/100.0
              valor_tot = price - valor_subeditor
              valor_editora = valor_tot*porcentaje_editora
              valor_editora -= valor_editora*params[:descuento].to_f/100.0
              valor_interprete = valor_tot*porcentaje_interprete
              valor_interprete -= valor_interprete*params[:descuento].to_f/100.0
              data = [id_obra, obra.Nombre_obra, Agrupacion.find(obra.Id_grupo).Nombre_grupo, aparicion.Territorio,porcentaje_interprete, porcentaje_editora,porcentaje_subeditora,price , valor_subeditor ,valor_editora, valor_interprete, obra.Editora  ]
    
              col = 0
              data.each do |cl|
                worksheet.add_cell(row,col,cl)
                col += 1
              end
              row += 1
            end
            
          end
        end
  
      send_data workbook.stream.string, filename: "liquidacionFonografico.xlsx",
                                    disposition: 'attachment'
  end
  def executeLiquidarGeneralFonografico
    
      workbook = RubyXL::Workbook.new
      worksheet = workbook.add_worksheet('liquidacion')
        headers = ['id obra', 'obra', 'grupo interprete', 'territorio', 'porcentaje interprete', 'porcentaje editora', 'porcentaje sub editora','valor reportado', 'valor sub editora', 'valor editora', 'valor interprete' , 'editora']
        col = 0
  
        headers.each do |hd|
          worksheet.add_cell(0,col,hd)
          col += 1
        end
        usuario = params[:grupo]
        fecha_i = params[:fecha_inicio]
        fecha_f = params[:fecha_fin]
        row = 1
        Aparicion.joins(" INNER JOIN Obra ON Aparicion.Id_obra = Obra.Id_obra").where("Obra.Id_grupo = ? AND Aparicion.fecha >= ? AND Aparicion.fecha <= ?", usuario, fecha_i, fecha_f).each do |aparicion|
            id_obra = aparicion.Id_obra
            price = aparicion.Precio*params[:euro].to_f*params[:dolar].to_f/1.19
            obra = Obra.where("Id_obra=?", id_obra)[0]
            if(obra != nil)
              porcentaje_interprete = obra.Porcentaje_interprete_fon
              porcentaje_editora = obra.Porcentaje_editora_fon
              porcentaje_subeditora = obra.Porcentaje_subeditor_fon
              valor_subeditor = price*porcentaje_subeditora;
              valor_subeditor -= valor_subeditor*params[:descuento].to_f/100.0
              valor_tot = price - valor_subeditor
              valor_editora = valor_tot*porcentaje_editora
              valor_editora -= valor_editora*params[:descuento].to_f/100.0
              valor_interprete = valor_tot*porcentaje_interprete
              valor_interprete -= valor_interprete*params[:descuento].to_f/100.0
              data = [id_obra, obra.Nombre_obra, Agrupacion.find(obra.Id_grupo).Nombre_grupo, aparicion.Territorio,porcentaje_interprete, porcentaje_editora,porcentaje_subeditora,price , valor_subeditor ,valor_editora, valor_interprete, obra.Editora  ]
    
              col = 0
              data.each do |cl|
                worksheet.add_cell(row,col,cl)
                col += 1
              end
              row += 1
            end
            
          end
        
  
      send_data workbook.stream.string, filename: "liquidacionFonografico.xlsx",
                                    disposition: 'attachment'      
    end
end
