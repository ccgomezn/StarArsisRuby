class IndexController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
  end

  def executeLoadAgrupation
    agrupacion = Agrupacion.create(Id_grupo: params[:id_agrupacion], Nombre_grupo: params[:nombre_agrupacion], Id_genero: params[:id_genero], Id_tipo_banda: params[:id_tipo_agrupacion])
    integrantes = params[:integrantes]

    integrantes.each do |id|
      grupo_contratante = GrupoContratante.create(Id_grupo: params[:id_agrupacion], Id_contratante: id)
    end
  end

  def executeLoadClient

    cliente = Contratante.create(Id_contratante: params[:id_cliente], Nombre_contratante: params[:nombre_cliente], Correo_contratante: params[:email], Direccion_contratante: params[:direccion], Ciudad_contratante: params[:ciudad])
    tipos_contratante = params[:tipo_usuario]

    tipos_contratante.each do |id|
      cliente_tipo_contratante = ContratanteTipoContratante.create(id_Contratante: params[:id_cliente], id_Tipo_contratante: id)
    end
  end

  def executeLoadFileById
    data_doc = params[:document]
    data_no_subida = []
    for i in 0..(params[:fila_inicio].to_i - 1)
      data_doc.delete(0)
    end
    data_doc.each do |row|
      if (row[params[:col_id].to_i] != nil)
        if (params[:tipo_aparicion].to_i === 1)
          id_obra = Obra.find_by(Id_obra: row[params[:col_id].to_i])
        else
          id_obra = ObraAutoral.find_by(Id_obra: row[params[:col_id].to_i])
        end


        if (id_obra != nil)
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
    reporte = Reporte.create(Id_reporte: nil, Doc_reporte: params[:document_blob], Estado_pago: 0, Fecha: params[:fecha], Id_socio: id_socio, Id_tipo_aparicion: params[:tipo_aparicion], Nombre_reporte: nombre_reporte, Comentario: params[:comentario], Mas_iva: params[:mas_iva], Iva_incluido: params[:iva_incluido], Descuento: params[:descuento], EURO_DOLAR: params[:euro_dolar], DOLAR_PESO: params[:dolar_peso], Territorio: params[:territorio])
    reporte = Reporte.last
    data_no_subida = []

    if (params[:socio].to_i === 6)
      i = 0
      data_load = []
      query_nombres = ''
      data_doc.each do |line|
        if (i == 0)
          i += 1

          next
        end
        if (line[47..79] != nil)
          nombre_obra = line[47..79].strip.upcase

          precio = (line[286..295].to_i / 100.0).round
          data_load.push([nombre_obra, precio])
          if nombre_obra.include? "'"
            query_nombres = query_nombres + '"' + nombre_obra + '",'
          else
            query_nombres = query_nombres + "'" + nombre_obra + "',"

          end
        end
      end
      query_nombres = query_nombres + "' '"
      word_dics = Diccionario.where('Entrada IN (' + query_nombres + ')')
      map_word_dics = {}
      word_dics.each do |row|
        map_word_dics["#{row.Entrada}"] = row.Salida
      end
      data_load.each do |row_data|
        unless (map_word_dics["#{row_data[0]}"].nil?)
          row_data[0] = map_word_dics["#{row_data[0]}"]
        end
      end

      query_nombres = ''
      data_load.each do |row_data|
        if row_data[0].include? "'"
          query_nombres = query_nombres + '"' + row_data[0] + '",'
        else
          query_nombres = query_nombres + "'" + row_data[0] + "',"

        end
      end
      query_nombres = query_nombres + "' '"
      if (params[:tipo_aparicion].to_i === 1)

        data_songs_load = Obra.where('Nombre_obra IN (' + query_nombres + ')')
      else
        data_songs_load = ObraAutoral.where('Nombre_obra IN (' + query_nombres + ')')
      end
      map_song_dics = {}
      data_songs_load.each do |row|
        map_song_dics["#{row.Nombre_obra}"] = row.Id_obra
      end
      data_load.each do |row_data|
        if (!map_song_dics["#{row_data[0]}"].nil?)
          row_data[0] = map_song_dics["#{row_data[0]}"]
          row_data[2] = 1
        else
          row_data[2] = 0
        end
      end
      data_real_to_load = []

      data_load.each do |row_data|
        if (row_data[2] == 1)
          data_real_to_load.push([row_data[0], reporte.Id_reporte, id_socio, row_data[1], params[:fecha]])
        else
          data_no_subida.push(row_data[0])
        end
      end
      columns = [:Id_obra, :Id_reporte, :Id_socio, :Precio, :Fecha]

      Aparicion.import columns, data_real_to_load

    else
      formato = FormatoDocumento.find(id_socio)
      data_no_subida = []
      for i in 0..(formato.fila_inicial - 1)
        data_doc.delete(0)
      end
      data_load = []
      slq_obr_dic = ''
      data_doc.each do |row|
        nombre_obra = row[formato.nombre_obra]
        unless (nombre_obra.nil? or nombre_obra == '')
          nombre_obra = nombre_obra.upcase.encode('UTF-8', :invalid => :replace, :undef => :replace)



          precio = row[formato.precio]

          if (formato.tipo_aparicion == nil)
            tipo_aparicion = nil
          else
            tipo_aparicion = row[formato.tipo_aparicion]
          end
          if (formato.duracion == nil)
            duracion = nil
          else
            duracion = row[formato.duracion].encode('UTF-8', :invalid => :replace, :undef => :replace)
          end
          if (formato.cantidad == nil)
            cantidad = nil
          else
            cantidad = row[formato.cantidad].encode('UTF-8', :invalid => :replace, :undef => :replace)
          end
          if (formato.fecha == nil)
            fecha = nil
          else
            fecha = row[formato.fecha].encode('UTF-8', :invalid => :replace, :undef => :replace)
          end
          if (formato.territorio == nil)
            territorio = nil
          else
            territorio = row[formato.territorio].encode('UTF-8', :invalid => :replace, :undef => :replace)
          end
          if (formato.medio_aparicion == nil)
            medio_aparicion = nil
          else
            medio_aparicion = row[formato.medio_aparicion].encode('UTF-8', :invalid => :replace, :undef => :replace)
          end
          if nombre_obra.include? "'"
            slq_obr_dic = slq_obr_dic + '"' + nombre_obra + '",'
          else
            slq_obr_dic = slq_obr_dic + "'" + nombre_obra + "',"

          end

          data_load.push([nombre_obra, precio, duracion, cantidad, params[:fecha], territorio, medio_aparicion])

        end
      end

      slq_obr_dic = slq_obr_dic + '" "'
      word_dics = Diccionario.where('Entrada IN (' + slq_obr_dic.encode('UTF-8', :invalid => :replace, :undef => :replace) + ')')
      map_word_dics = {}

      word_dics.each do |row|
        entr = row.Entrada.encode('UTF-8', :invalid => :replace, :undef => :replace)
        salida = row.Salida.encode('UTF-8', :invalid => :replace, :undef => :replace)
        map_word_dics["#{entr}"] = salida
      end
      data_load.each do |row_data|
        key = row_data[0].encode('UTF-8', :invalid => :replace, :undef => :replace)
        unless (map_word_dics["#{key}"].nil?)
          row_data[0] = map_word_dics["#{key}"].encode('UTF-8', :invalid => :replace, :undef => :replace)
        end
      end

      query_nombres = ''
      data_load.each do |row_data|
        if row_data[0].include? "'"
          query_nombres = query_nombres + '"' + row_data[0].encode('UTF-8', :invalid => :replace, :undef => :replace) + '",'
        else
          query_nombres = query_nombres + "'" + row_data[0].encode('UTF-8', :invalid => :replace, :undef => :replace) + "',"

        end
      end
      query_nombres = query_nombres + "' '"
      if (params[:tipo_aparicion].to_i === 1)

        data_songs_load = Obra.where('Nombre_obra IN (' + query_nombres.encode('UTF-8', :invalid => :replace, :undef => :replace) + ')')
      else
        data_songs_load = ObraAutoral.where('Nombre_obra IN (' + query_nombres.encode('UTF-8', :invalid => :replace, :undef => :replace) + ')')
      end
      map_song_dics = {}
      data_songs_load.each do |row|
        map_song_dics["#{row.Nombre_obra.encode('UTF-8', :invalid => :replace, :undef => :replace)}"] = row.Id_obra
      end
      data_load.each do |row_data|
        if (!map_song_dics["#{row_data[0].encode('UTF-8', :invalid => :replace, :undef => :replace)}"].nil?)
          row_data[0] = map_song_dics["#{row_data[0].encode('UTF-8', :invalid => :replace, :undef => :replace)}"]
          row_data[7] = 1
        else
          row_data[7] = 0
        end
      end
      data_real_to_load = []

      data_load.each do |row_data|
        if (row_data[7] == 1)
          data_real_to_load.push([row_data[0], reporte.Id_reporte, id_socio, row_data[1], row_data[2], row_data[3], row_data[4], row_data[5], row_data[6]])
        else
          data_no_subida.push(row_data[0])
        end
      end
      columns = [:Id_obra, :Id_reporte, :Id_socio, :Precio, :Duracion, :Cantidad, :Fecha, :Territorio, :Id_medio_aparicion]

      Aparicion.import columns, data_real_to_load


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
    headers = ['id obra', 'obra', 'id autor', 'nombre autor', 'territorio', 'porcentaje_autor', 'porcentaje_editora', 'valor reportado', 'valor editora', 'valor autor', 'catalogo']
    col = 0

    headers.each do |hd|
      worksheet.add_cell(0, col, hd)
      col += 1
    end

    row = 1
    for i in 0..(params[:n_reports].to_i - 1)

      id_reporte = params[:"report_#{i}"]
      reporte = Reporte.find(id_reporte)
      iva_incluido = reporte.Iva_incluido
      mas_iva = reporte.Mas_iva
      descuento = reporte.Descuento
      Aparicion.where("Id_reporte = ?", id_reporte).each do |aparicion|
        id_obra = aparicion.Id_obra
        price = aparicion.Precio
        price = price / (1 + (iva_incluido.to_f))
        price = price - price * (mas_iva.to_f)
        price = price - price * (descuento.to_f)
        obra = ObraAutoral.where("Id_obra=? AND Catalogo=?", id_obra, params[:catalogo])[0]
        if (obra != nil)
          if (reporte.Territorio == 1)
            porcentaje_autor = obra.Porcentaje_colombia
            porcentaje_editora = obra.Porcentaje_editora_colombia
            territorio = 'Nacional'
          else
            porcentaje_autor = obra.Porcentaje_internacional
            porcentaje_editora = obra.Porcentaje_editora_internacional
            territorio = 'Internacional'

          end
          if (Contratante.find_by(Id_contratante: obra.Autor_id) != nil)
            nombre_contratante = Contratante.find_by(Id_contratante: obra.Autor_id).Nombre_contratante

          else
            nombre_contratante = 'Autor no reconocido'
          end
          price_editora = porcentaje_editora * price
          price_autor = porcentaje_autor * price

          data = [id_obra, obra.Nombre_obra, obra.Autor_id, nombre_contratante, territorio, porcentaje_autor, porcentaje_editora, price.to_i, price_editora.to_i, price_autor.to_i, obra.Catalogo]


          col = 0
          data.each do |cl|
            worksheet.add_cell(row, col, cl)
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
    headers = ['id obra', 'obra', 'id autor', 'nombre autor', 'territorio', 'porcentaje_autor', 'porcentaje_editora', 'valor reportado', 'valor editora', 'valor autor', 'catalogo']
    col = 0

    headers.each do |hd|
      worksheet.add_cell(0, col, hd)
      col += 1
    end
    usuario = params[:usuario]
    fecha_i = params[:fecha_inicio]
    fecha_f = params[:fecha_fin]
    row = 1
    acomu = {}
    acomu_t = 0
    Aparicion.joins(" INNER JOIN Obra_autoral ON Aparicion.Id_obra = Obra_autoral.Id_obra").where("Obra_autoral.Autor_id = ? AND Aparicion.fecha >= ? AND Aparicion.fecha <= ?", usuario, fecha_i, fecha_f).each do |aparicion|
      id_obra = aparicion.Id_obra
      id_reporte = aparicion.Id_reporte
      reporte = Reporte.find(id_reporte)
      iva_incluido = reporte.Iva_incluido
      mas_iva = reporte.Mas_iva
      descuento = reporte.Descuento
      price = aparicion.Precio
      price = price / (1 + (iva_incluido.to_f))
      price = price - price * (mas_iva.to_f)
      price = price - price * (descuento.to_f)
      obra = ObraAutoral.where("Id_obra=?", id_obra)[0]
      if (obra != nil)
        if (reporte.Territorio == 1)
          porcentaje_autor = obra.Porcentaje_colombia
          porcentaje_editora = obra.Porcentaje_editora_colombia
          territorio = 'Nacional'
        else
          porcentaje_autor = obra.Porcentaje_internacional
          porcentaje_editora = obra.Porcentaje_editora_internacional
          territorio = 'Internacional'
        end
        if (Contratante.find_by(Id_contratante: obra.Autor_id) != nil)
          nombre_contratante = Contratante.find_by(Id_contratante: obra.Autor_id).Nombre_contratante

        else
          nombre_contratante = 'Autor no reconocido'
        end
        price_editora = porcentaje_editora * price
        price_autor = porcentaje_autor * price

        data = [id_obra, obra.Nombre_obra, obra.Autor_id, nombre_contratante, territorio, porcentaje_autor, porcentaje_editora, price.to_i, price_editora.to_i, price_autor.to_i, obra.Catalogo]
        if(acomu["#{obra.Nombre_obra}"].nil?)
                    acomu["#{obra.Nombre_obra}"] = price_autor.to_i;
                else
                     acomu[obra.Nombre_obra] +=  price_autor.to_i;
                end

         acomu_t +=  price_autor.to_i;

        col = 0
        data.each do |cl|
          worksheet.add_cell(row, col, cl)
          col += 1
        end
        row += 1
      end

    end

    row += 5;
    worksheet.add_cell(row, 0, 'Obra')
    worksheet.add_cell(row, 1, 'Valor acomulado')
    row += 1;
    acomu.each do |k, v|
          worksheet.add_cell(row, 0, k)
          worksheet.add_cell(row, 1, v)
          row += 1;
    end
     worksheet.add_cell(row, 0, 'TOTAL')
              worksheet.add_cell(row, 1, acomu_t)
              row += 1;
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

    def loadClient
            @clientes = Array.new()
            Contratante.find_each do |obra|
              @clientes.push(obra)
            end
          end

          def loadAgrupation
                  @clientes = Array.new()
                  Agrupacion.find_each do |obra|
                    obra_real = {}
                    obra_real["Nombre_grupo"] = obra.Nombre_grupo
                    obra_real["Id_grupo"] = obra.Id_grupo
                    genero = GeneroMusical.find_by(id: obra.Id_genero).Nombre_genero
                    tipo = TipoAgrupacion.find_by(id: obra.Id_tipo_banda).Nombre_tipo_banda
                    obra_real["Id_genero"] = genero
                    obra_real["Id_tipo_banda"] = tipo

                    @clientes.push(obra_real)
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
    Aparicion.where("Id_reporte =?", params[:id]).each do |ap|
      Aparicion.find(ap.Id_aparicion).destroy
    end
    redirect_to "/index/liquidar"

  end

  def deleteFonografico
    Reporte.find(params[:id]).destroy
    Aparicion.where("Id_reporte =?", params[:id]).each do |ap|
      Aparicion.find(ap.Id_aparicion).destroy
    end
    redirect_to "/index/liquidar_fonografico"

  end

  def executeLiquidarFonografico

    workbook = RubyXL::Workbook.new
    worksheet = workbook.add_worksheet('liquidacion')
    headers = ['id obra', 'obra', 'grupo interprete', 'territorio', 'porcentaje interprete', 'porcentaje editora', 'porcentaje sub editora', 'valor reportado', 'valor sub editora', 'valor editora', 'valor interprete', 'editora']
    col = 0

    headers.each do |hd|
      worksheet.add_cell(0, col, hd)
      col += 1
    end

    row = 1
    for i in 0..(params[:n_reports].to_i - 1)
      id_reporte = params[:"report_#{i}"]
      reporte = Reporte.find(id_reporte)
      iva_incluido = reporte.Iva_incluido
      mas_iva = reporte.Mas_iva
      descuento = reporte.Descuento
      euro = reporte.EURO_DOLAR
      dolar = reporte.DOLAR_PESO
      Aparicion.where("Id_reporte = ?", id_reporte).each do |aparicion|
        id_obra = aparicion.Id_obra
        price = aparicion.Precio * euro * dolar
        price = price / (1 + (iva_incluido.to_f))
        price = price - price * (mas_iva.to_f)
        price = price - price * (descuento.to_f)
        obra = Obra.where("Id_obra=? AND Editora=?", id_obra, params[:catalogo])[0]
        if (obra != nil)
          porcentaje_interprete = obra.Porcentaje_interprete_fon
          porcentaje_editora = obra.Porcentaje_editora_fon
          porcentaje_subeditora = obra.Porcentaje_subeditor_fon
          valor_subeditor = price * porcentaje_subeditora
          valor_tot = price - valor_subeditor
          valor_editora = valor_tot * porcentaje_editora
          valor_interprete = valor_tot * porcentaje_interprete
          data = [id_obra, obra.Nombre_obra, Agrupacion.find(obra.Id_grupo).Nombre_grupo, aparicion.Territorio, porcentaje_interprete, porcentaje_editora, porcentaje_subeditora, price.to_i, valor_subeditor.to_i, valor_editora.to_i, valor_interprete.to_i, obra.Editora]

          col = 0
          data.each do |cl|
            worksheet.add_cell(row, col, cl)
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
    headers = ['id obra', 'obra', 'grupo interprete', 'persona grupo', 'territorio', 'porcentaje interprete', 'porcentaje editora', 'porcentaje sub editora', 'valor reportado', 'valor sub editora', 'valor editora', 'valor interprete', 'editora']
    col = 0

    headers.each do |hd|
      worksheet.add_cell(0, col, hd)
      col += 1
    end
    usuario = params[:grupo]
    fecha_i = params[:fecha_inicio]
    fecha_f = params[:fecha_fin]
    row = 1
    grupo = GrupoContratante.joins(" INNER JOIN Contratante ON Grupo_contratante.Id_contratante = Contratante.Id_contratante").where("Grupo_contratante.Id_grupo = ?", usuario)
    grupo_real = []
    ln = 0
    if (grupo == nil)
      grupo_real = ["Integrantes no identificados"]
      ln = 1
    else
      grupo.each do |integrante|
        grupo_real.push(Contratante.find(integrante.Id_contratante.to_i).Nombre_contratante)
        ln += 1
      end

      puts grupo
      puts grupo_real
    end
    acomu = {}
    total = 0
    Aparicion.joins(" INNER JOIN Obra ON Aparicion.Id_obra = Obra.Id_obra").where("Obra.Id_grupo = ? AND Aparicion.fecha >= ? AND Aparicion.fecha <= ?", usuario, fecha_i, fecha_f).each do |aparicion|
      id_obra = aparicion.Id_obra

      id_reporte = aparicion.Id_reporte
      reporte = Reporte.find(id_reporte)
      iva_incluido = reporte.Iva_incluido
      mas_iva = reporte.Mas_iva
      descuento = reporte.Descuento
      euro = reporte.EURO_DOLAR
      dolar = reporte.DOLAR_PESO
      price = aparicion.Precio * dolar * euro / ln

      price = price / (1 + (iva_incluido.to_f))
      price = price - price * (mas_iva.to_f)
      price = price - price * (descuento.to_f)
      obra = Obra.where("Id_obra=?", id_obra)[0]
      if (obra != nil)
        porcentaje_interprete = obra.Porcentaje_interprete_fon
        porcentaje_editora = obra.Porcentaje_editora_fon
        porcentaje_subeditora = obra.Porcentaje_subeditor_fon
        valor_subeditor = price * porcentaje_subeditora;
        valor_subeditor -= valor_subeditor * params[:descuento].to_f / 100.0
        valor_tot = price - valor_subeditor
        valor_editora = valor_tot * porcentaje_editora
        valor_editora -= valor_editora * params[:descuento].to_f / 100.0
        valor_interprete = valor_tot * porcentaje_interprete
        valor_interprete -= valor_interprete * params[:descuento].to_f / 100.0
        grupo_real.each do |interprete|

          data = [id_obra, obra.Nombre_obra, Agrupacion.find(obra.Id_grupo).Nombre_grupo, interprete, aparicion.Territorio, porcentaje_interprete, porcentaje_editora, porcentaje_subeditora, price.to_i, valor_subeditor.to_i, valor_editora.to_i, valor_interprete.to_i, obra.Editora]
          if(acomu[obra.Nombre_obra].nil?)
            acomu[obra.Nombre_obra] = valor_interprete.to_i
          else
            acomu[obra.Nombre_obra] += valor_interprete.to_i
          end

          total += valor_interprete.to_i

          col = 0
          data.each do |cl|
            worksheet.add_cell(row, col, cl)
            col += 1
          end
          row += 1
        end

      end

    end

    row += 5;
    count = 1;
    grupo_real.each do |integrante|
                  worksheet.add_cell(row, 0, count)
                  worksheet.add_cell(row, 1, integrante)
                                        count +=1;
                        row += 1;
    end
    count = 1;
    row += 1;
    worksheet.add_cell(row, 0, 'Obra')

    grupo_real.each do |integrante|
                      worksheet.add_cell(row, count, count)
                      count +=1;
        end
     row += 1;
    acomu.each do |key, val|
       worksheet.add_cell(row, 0, key)
     count = 1;
     r_val = val/grupo_real.length
     grupo_real.each do |integrante|
                           worksheet.add_cell(row, count, r_val)
                                count +=1;
             end
                                              row += 1;

    end


    send_data workbook.stream.string, filename: "liquidacionFonografico.xlsx",
              disposition: 'attachment'
  end
end
