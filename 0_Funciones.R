##################################################################
# Elabora: Germán Gáldamez                                       #
# Fecha: 01 Marzo 2024                                           #
# Evento: Evaluación 2025                                        #
# Funciones                                                      #
##################################################################

##################################################################
# Instalar y leer librerías,directorio princial                  #
##################################################################

#Vector de todos los paquetes a instalar
paquetes<-c("readxl","tidyr","xlsx","devtools","rlang","stringr","sqldf","Hmisc",'car',"tidyverse",
            "tidytext","tm","lubridate","zoo","scales","SnowballC",'wordcloud',"gmodels","rgdal",
            'fmsb',"ggplot2","scales","reshape2","tibble",'radarchart','data.table',"devtools","sf",
            "tmap","dplyr","haven","ggsci","ggrepel","ggpubr",'magick','shadowtext',"likert",
            "Rcpp","xfun","stringi","rstudioapi","gdata","plotly")

#install.packages("stringi", configure.args = "--disable-pkg-config")

# Instalar paquetes en caso de no estyar instalado
installed_packages <- paquetes %in% rownames(installed.packages())
installed_packages

#Verificar que las librerias esten cargadas
if (any(installed_packages == FALSE)) {
  install.packages(paquetes[!installed_packages])
}

# Cargar todo los paquetes de la lista
invisible(lapply(paquetes, library, character.only = TRUE))


estructura_carpeta<-function(Direct,Etapa){
# Se crea el directorio del proyecto
dir.create(Direct)

  # Se crea la carpeta de trabajo dentro del directorio
  dir.create(file.path(Direct, Etapa))

    # Dentro de la carpeta de trabajo, se crean subcarpetas
    dir.create(file.path(Direct, Etapa, "CATALAGO"))
    dir.create(file.path(Direct, Etapa, "RESULTADO"))
    dir.create(file.path(Direct, Etapa, "TABLAS"))

      #En cada subcarpetas se crean otras, es para diferenciar de la tabla, gráficoss, etc.
      #En GRAFICAS,se crean otras carpetas para diferencial del tipo de gráficos
      sub_folder<-paste("GRAFICAS",format(Sys.Date(),format="%d%m%Y"),sep="_")
      dir.create(file.path(Direct, Etapa, "RESULTADO",sub_folder))

        dir.create(file.path(Direct, Etapa, "RESULTADO",sub_folder,"FRECUENCIAS"))
          dir.create(file.path(Direct, Etapa, "RESULTADO",sub_folder,"FRECUENCIAS","INDICADORES"))
          dir.create(file.path(Direct, Etapa, "RESULTADO",sub_folder,"FRECUENCIAS","VARIABLES"))

        dir.create(file.path(Direct, Etapa, "RESULTADO",sub_folder,"INDICADORES"))
          dir.create(file.path(Direct, Etapa, "RESULTADO",sub_folder,"INDICADORES","INDICADORES"))
          dir.create(file.path(Direct, Etapa, "RESULTADO",sub_folder,"INDICADORES","VARIABLES"))

        dir.create(file.path(Direct, Etapa, "RESULTADO",sub_folder,"TEXTO"))

# Confirm folder structure creation
list.files(Direct, recursive = TRUE)
}

#==================================================================
#Separa cadena de texto donde hay parentesis
#==================================================================
x_extract1 <- function(x){gsub("[\\(\\)]","",
                               regmatches(x,gregexpr("(?<=\\().*?(?=\\))",x,perl=TRUE))
)
}

#==================================================================
#Remover filas y columnas totalmente vacias
#==================================================================
elimineempty_rowcol<-function(df){
  #eliminar columnas vacias
  empty_columns <- sapply(df, function(x) all(is.na(x) | x == ""))
  df=df[, !empty_columns]

  #eliminar celdaS vacias
  cols <- ncol(df)
  is_na <- is.na(df)
  row_na <- rowSums(is_na)
  df <- df[row_na != cols, ]

  #eliminar celdas que tienen NA's
  df<-df[rowSums(is.na(df)) != ncol(df), ]
}

#==================================================================
#Para leer múltiples archivos excel
#==================================================================
read_file_xlsx<-function(file,shet){
  lapply(file, function(i)
  {x = read.xlsx(i, sheetIndex=shet, check.names=FALSE, #sheetName=NULL, startRow=5,
                 endRow=NULL, as.data.frame=TRUE, header=T)
  x$archivo = i
  x
  })
}

read_file_csv<-function(file){
  lapply(file, function(i)
  {x = read.csv(i,header=T,encoding = "UTF-8")
  x$archivo = i
  x
  })
}


#==================================================================
#Limpieza de texto: salto, caracter especial
#==================================================================
trat_strint<-function(list){
  list=gsub("[\r\n]", "/",list)
  list=gsub("[\r]", "",list)
  list=gsub("\\s",  " ",list)
  list=gsub(";;",   ";",list)
  list=gsub(",",   "",list)
  list=gsub("; ",   ";",list)
  list=gsub("\\.(?=[^.]*\\.)", "", list, perl=TRUE)
  list=gsub("[/]", " ", list)
  list=str_replace_all(list, "[\r\n]" , "")
  list=str_trim(list, "right")
  list=str_trim(list, "left")
  list=stri_trim_both(list)
  list=gsub('\U00AD', '', list)
  list=stri_remove_empty_na(list)
  list=stri_trans_general(list, id="Latin-ASCII")
  #list=tolower(list)
  list=gsub('[^[:alnum:]_]','',list)
  list=gsub('[\t\n]','',list)
  list=gsub("[^[:alnum:][:blank:]+?¿&/\\-_]", "", list)
  list=gsub("[[\t\n]+?¿&/\\-_]", "",list)
  return(list)
}

trat_resp<-function(list){
  list=sub("[^a-zA-Z0-9]+$", "", list)
  list=gsub("[\r\n]", "/",list)
  list=gsub("[\r]", "",list)
  list=gsub("\\s",  " ",list)
  list=gsub(";;",   ";",list)
  list=gsub(",",   "",list)
  list=gsub("; ",   ";",list)
  list=gsub("\\.(?=[^.]*\\.)", "", list, perl=TRUE)
  list=gsub("[/]", " ", list)
  list=str_replace_all(list, "[\r\n]" , "")
  list=str_trim(list, "right")
  list=str_trim(list, "left")
  list=stri_trim_both(list)
  list=gsub('\U00AD', '', list)
  list=stri_remove_empty_na(list)
  list=stri_trans_general(list, id="Latin-ASCII")
  list=tolower(list)
  #list=gsub('[^[:alnum:] ]','',list)
  list=gsub('[\t\n]','',list)
  #list=gsub("[^[:alnum:][:blank:]+?¿&/\\-]", "", list)
  list=gsub("[[\t\n]+?¿&/\\-]", "",list)
  return(list)
}

#==================================================================
# Extrae letras de derecha a izquierda
#==================================================================
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}

#==================================================================
#
#==================================================================
union<-function(df){
  x<-stri_trim_both(unlist(strsplit(df$Respuestas,split=";")))
  y<-stri_trim_both(unlist(strsplit(df$Respuestas_c,split=";")))

  paste0("'",x,"'"," = ","'",y,"'",collapse=", ")
}


#==================================================================
# Reemplazar respuestas por valores en toda la tabla
#==================================================================

reemplazo<-function(df,list_var)
{
  for(i in 1:length(list_var))
  {
    print(paste0("Variable","---",list_var[i]))

    columna=which(names(df) %in% c(list_var[i]))

    VEC_AUX=as.character(unlist(df[,columna]))

    RESP<-VAL_COD%>%filter(Mnemonicos==list_var[i])%>% select(Respuestas,Codigo)
    NIVELES_RESP<-stri_trim_both(as.vector(unlist(RESP[,1])))
    NIVELES_CLAV<-stri_trim_both(as.vector(unlist(RESP[,2])))

    sort.by.length.desc <- function (v) v[order( -nchar(v)) ]
    regex <- paste0("\\b(",paste(sort.by.length.desc(NIVELES_RESP), collapse="|"), ")\\b")

    VEC_AUX=str_replace_all(VEC_AUX, regex, function(word) as.character(NIVELES_CLAV)[NIVELES_RESP==word][[1]][1])
    #VEC_AUX=str_replace_all(VEC_AUX, setNames(NIVELES_CLAV, NIVELES_RESP))

    #df[,columna]<-VEC_AUX
    df[i][,columna] <- VEC_AUX
  }

}



#==================================================================
#Función para ajustar texto
#==================================================================
ajuste<-function(x) {
  if(str_length(x)>100){
    str_wrap(x, width=50)
  }else {str_wrap(x, width=60)}
}


#==================================================================
# Para colocar el % en los gráficos de barra
#==================================================================

etiquetar_numero=function(x,decimales,quitar_cero=0,etiquetar='')
{
  x[is.na(x)]=0
  x=round(x,decimales)
  x_txt=as.character(x)
  if(sum(str_detect(x_txt,"[.]"))==0){
    X2=rep(paste0(rep('0',decimales),collapse=''),length(x_txt))
    x_txt=data.frame(X1=x_txt,X2=X2)
    etiqueta=apply(x_txt,1,paste0,collapse='.')
  }else{
    x_txt=separar_texto(x_txt,'[.]')

    x_txt$largo=nchar(x_txt$X2)
    for(i in 1:nrow(x_txt)){
      if(x_txt$largo[i]==decimales){next
      }else{
        if(x_txt$X2[i]==' '){x_txt$X2[i]=paste0(rep('0',decimales),collapse='')}else{
          diferencia=decimales-x_txt$largo[i]
          x_txt$X2[i]=paste0(x_txt$X2[i],paste0(rep('0',diferencia),collapse=''),collapse='')
        }

      }
    }
    x_txt=x_txt %>% select(X1,X2)
    if(etiquetar==''){etiqueta=apply(x_txt,1,paste0,collapse='.')}
    else{
      etiqueta=data.frame(etiqueta=apply(x_txt,1,paste0,collapse='.'),etiquetar)
      etiqueta=apply(etiqueta,1,paste0,collapse='')
    }
  }
  if(quitar_cero==1){
    etiqueta_aux=str_remove_all(etiqueta,pattern=etiquetar)
    etiqueta[which(as.numeric(etiqueta_aux)==0)]=''}
  return(etiqueta)
}

#==================================================================
# Fragmentar cadena de texto cuando son muy grandes
#==================================================================
separar_texto=function(vector,separador)
{
  maximo=max(unlist(lapply(strsplit(vector,separador),length)))
  data_aux=data.frame(matrix('',ncol=maximo,nrow=length(vector)))
  for(i in 1:length(vector))
  {
    if(length(strsplit(vector,separador)[[i]])<maximo)
    {data_aux[i,]=c(strsplit(vector,separador)[[i]],rep(' ',maximo-length(strsplit(vector,separador)[[i]])))}
    else{
      data_aux[i,]=strsplit(vector,separador)[[i]]
    }
  }
  return(data_aux)
}

#==================================================================
# Detecta columnas con que contienen letras en una tabla
#==================================================================
detect_anycharacter<-function(df){
  vect<-unique(as.vector(unlist((apply(df, 1,function(x) str_extract_all(x,'(?![-;/&,])[^[Aa-zZ]]'))))))
  if (any(grepl("[A-Za-z]", vect))==T) {
    0
    #print("existe variables con letras")
  } else {1}
}


#==================================================================
# Exportar multiples tablas en un archivo XLSX
#==================================================================
Export_xlsx<-function(path,lista_df,nombre){
  file <- paste(path,paste0(nombre,".xlsx"), sep="/")
  wb <- createWorkbook()
  sheetnames <- paste0("Ind", seq_along(lista_df)) # or names(datas) if provided
  sheets <- lapply(sheetnames, createSheet, wb = wb)
  void <- Map(addDataFrame, lista_df, sheets)
  saveWorkbook(wb, file = file)
}



#==================================================================
# Exportar multiples tablas en un archivo .db (base de datos SQlite)
#==================================================================
codifcar_df<-function(df,variables,tipo){

  for(i in 1:length(variables)){
    print(paste0("Variable","---",variables[i]))

    columna=which(names(df) %in% c(variables[i]))

    VEC_AUX=as.character(unlist(df[,columna]))
    if (tipo=="codigo"){
      RESP<-VAL_COD%>%filter(Mnemonicos==variables[i])%>% select(Respuestas,Codigo)
    }
    if (tipo=="peso"){
      RESP<-VAL_COD%>%filter(Mnemonicos==variables[i])%>% select(Respuestas,Clave)
    }


    NIVELES_RESP<-stri_trim_both(as.vector(unlist(RESP[,1])))
    NIVELES_CLAV<-stri_trim_both(as.vector(unlist(RESP[,2])))

    sort.by.length.desc <- function (v) v[order( -nchar(v)) ]
    regex <- paste0("\\b(",paste(sort.by.length.desc(NIVELES_RESP), collapse="|"), ")\\b")

    VEC_AUX=str_replace_all(VEC_AUX, regex, function(word) as.character(NIVELES_CLAV)[NIVELES_RESP==word][[1]][1])
    #VEC_AUX=str_replace_all(VEC_AUX, setNames(NIVELES_CLAV, NIVELES_RESP))

    df[,columna]=VEC_AUX
  }
  return(data.frame(df))

}


#==================================================================
#Colores de las barras, en un gráfico de barras
#==================================================================
cbp1 <- c("#252158", "#004F9F", "#0080C9", "#FF9E18","#A45A95", "#3DAE2B", "#009383", "#0095A9","#ffd903")
cbp2=colorRampPalette(cbp1,interpolate='linear')
proc_color=c('Capacitación','Evaluación','Documentación','Captura','Codificación','Validación','AIEMG','Cotejo','Total')
proc_color_table=data.frame(proc_color=proc_color,color=cbp1)


#==================================================================
#Función para los gráficos de barra, pastel, donas
#==================================================================
graficos<-function(df,tipo_grafico,Tit,Subt){

  plot_type<-tipo_grafico

  if (Subt=="General"){
    titulo<-Tit
  }else{
    titulo<-trim(paste(Tit,"<br> <sup>",Subt,"</sup>",sep=""))
  }


  colores<-as.vector(unlist(unique(proc_color_table$color)))
  font_title<-list(family = "sans-serif",size = 16,color = "black")
  font_yaxis<-list(family = "sans-serif",size = 14,color = "black")
  font_xaxis<-list(family = "sans-serif",size = 14,color = "black")
  font_leg  <-list(family = "sans-serif",size =  10,color = "black")
  font_tex  <-list(family = "sans-serif",size = 8,color = "black") #% por encima de las barras

  col=sample(colores, nrow(df))

  if (plot_type == "pie") {
    plot_ly(df,values=~df$Porcentaje,labels=~factor(df$Respuestas), type = "pie",
            textinfo = 'text', text = ~df$Text, width = 1200, height = 600,
            insidetextorientation = 'radial',
            marker = list(colors = col, line = list(color = '#FFFFFF', width = 2))
            #marker = list(colors = col),
            #textinfo=~df$Text
            #textinfo = list("label+percent",family = "sans-serif",size=12, color="black")#,text = ~df$Text
    ) %>%
      layout(title =list(text =titulo,y = 0.95, yanchor = "top",font = font_title),
             width = 100, height = 100,
             margin = list( l = 0, r = 0, b = 0, t = 70),
             legend = list(orientation = 'h',font = font_leg,xanchor = "center",x = 0.5),
             annotations = list(
               list(
                 text = "",
                 font = list(size = 12),
                 showarrow = FALSE,
                 x = 0.5,
                 y = 0.5,
                 xanchor = 'center',
                 yanchor = 'middle'
               )
             )
      )
  }else if (plot_type== "bar_v"){
    plot_ly(df,y=~df$Porcentaje,x=~factor(df$Respuestas), color=~factor(df$Respuestas),colors =col,
            type = "bar",text =~df$Text,textposition = 'outside',
            textfont=list(font_tex),width = 1200, height = 600,
            orientation = 'v',
            marker = list(line = list(color = col, width = 1))) %>%
      #add_text(text=~df$Text, hoverinfo="text", textposition = 'top', showlegend = FALSE,textfont=list(family = "sans-serif",size=12, color="black"))%>%
      layout(hovermode = 'x',bargap = 0.4,
             title = list(text =titulo,y = 0.95, yanchor = "top",font = font_title),
             margin = list(t = 100),
             #legend = list(orientation = 'h',font = font_leg,xanchor = "center",x = 0.5),
             legend = list(traceorder = 'reversed',orientation = 'h',font = font_leg),
             xaxis = list(title = "",showticklabels = FALSE),
             #yaxis = list(tickvals=seq(0,ifelse(max(df$Porcentaje)<100, (max(df$Porcentaje)+10),100),10),
             yaxis = list(title = "",tickvals=seq(0,100,10),ticksuffix = "%",  range = c(0, 110),tickfont=font_leg)
      )
    }else if (plot_type== "bar_h"){
      plot_ly(df,x=~df$Porcentaje,y=~factor(df$Respuestas), color=~factor(df$Respuestas),colors =col,
              type = "bar",text =~df$Text,textposition = 'outside',
              textfont=list(font_tex),width = 1200, height = 600,
              orientation = 'h',
              marker = list(line = list(color = col, width = 1))) %>%
        #add_text(text=~df$Text, hoverinfo="text", textposition = 'top', showlegend = FALSE,textfont=list(family = "sans-serif",size=12, color="black"))%>%
        layout(hovermode = 'x',bargap = 0.4,
               title = list(text =titulo,y = 0.95, yanchor = "auto",font = font_title),
               margin = list(t = 100),
               #legend = list(orientation = 'h',font = font_leg),  #,xanchor = "center",x = 0.5
               legend = list(traceorder = 'reversed',orientation = 'h',font = font_leg),
               #xaxis = list(tickvals=seq(0,ifelse(max(df$Porcentaje)<100, (max(df$Porcentaje)+10),100),10),
               xaxis = list(title = "", tickvals=seq(0,100,10),ticksuffix = "%",  range = c(0, 110),tickfont=font_leg),
               yaxis = list(title = "",showticklabels = FALSE,categoryorder = "trace")
        )

  }else if (plot_type== "pie"){
    plot_ly(df,labels = ~factor(df$Respuestas), values = ~df$Porcentaje,type = 'pie',
            textinfo = 'text', text = ~df$Text,width = 1200, height = 600,
            #textinfo = "label+percent",
            insidetextorientation = 'radial',
            marker = list(colors = col, line = list(color = '#FFFFFF', width = 2)))%>%
      #add_pie(hole = 0.6)%>%
      layout(title = list(text =titulo,y = 0.95, yanchor = "top",font = font_title),
             margin =list( l = 0, r = 0, b = 0, t = 70),
             showlegend = F,
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             annotations = list(
               list(
                 text = "",
                 font = font_leg,
                 showarrow = FALSE,
                 x = 0.5,
                 y = 0.5
               )
             )
      )

  }else if (plot_type== "donut"){
    plot_ly(df, labels = ~factor(df$Respuestas), values = ~df$Porcentaje,type = 'pie', hole = 0.5,
            #textinfo = 'label+percent',
            textinfo = 'text',
            text = ~paste0(df$Porcentaje,"%"),#width = 1200, height = 600,
            textposition ="inside",
            textfont = font_yaxis,
            hoverinfo = 'text',
            insidetextorientation = 'radial',
            marker = list(colors = col, line = list(color = '#FFFFFF', width = 2))) %>%
      layout(
        title = list(text =titulo,y = 0.95, yanchor = "top",font = font_title),
        showlegend = TRUE,
        xaxis = list(categoryorder = "trace",showgrid = FALSE, zeroline = FALSE, showticklabels = TRUE),
        yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = TRUE),
        margin = list(t = 100),  # Ajusta el margen superior
        legend = list(orientation = 'h',font = font_leg,xanchor = "center",x = 0.5),
        showlegend = TRUE
        #,annotations=list(text=~str_wrap(df$Preguntas,30), "showarrow"=F, font=font_yaxis)
      )

  }else if (plot_type== "funnel"){
    df<-arrange(df,desc(Porcentaje))
    plot_ly(df,y=as.vector(str_wrap(df$Respuestas,25)),x=~df$Porcentaje,type = "funnel",colors =col,
            textposition = "inside",
            textinfo = "percent total",
            textfont = list(size = 12),
            opacity = 0.65,
            marker = list(color = col)
    )%>%
      layout(
        title = list(text =titulo,y = 0.95, yanchor = "top",font = font_title),
        margin = list(t = 100),
        yaxis = list(categoryarray =~str_wrap(df$Respuestas,25),tickfont=font_yaxis)
      )

  }
}

#==================================================================
#Función para los gráficos de barra agrupados según Indicador
#==================================================================
graficos_agrup<-function(df,Tit,Subt){


  if (Subt=="General"){
    titulo<-Tit
  }else{
    titulo<-trim(paste(Tit,"<br> <sup>",Subt,"</sup>",sep=""))
  }


  colores<-as.vector(unlist(unique(proc_color_table$color)))
  font_title<-list(family = "sans-serif",size = 15,color = "black")
  font_yaxis<-list(family = "sans-serif",size = 12,color = "black")
  font_xaxis<-list(family = "sans-serif",size = 12,color = "black")
  font_leg  <-list(family = "sans-serif",size =  10,color = "black")
  font_tex  <-list(family = "sans-serif",size = 8,color = "black")

  col=sample(colores, length(unique(df$Preguntas)))
  df$Text<-ifelse(df$Porcentaje!=0,paste(df$Porcentaje,"%",sep=""),"")
  df$txt_position<-ifelse(df$Porcentaje<=20,"outside","inside")
  df$ancho<-ifelse(df$Porcentaje<=20,"outside","inside")

  #df$Preguntas <- factor(df$Preguntas, levels = unique(df$Preguntas))
  #df$Respuestas <- factor(df$Respuestas, levels =unique(df$Respuestas))
  #df <- df[order(df$V_Mnemonicos,df$Respuestas),]

  df$Respuestas<-ifelse(str_length(df$Respuestas)>40,str_wrap(df$Respuestas, 30),df$Respuestas)

  checando<-data.frame(aggregate(df$Respuestas, by=list(df$V_Mnemonicos,df$Tipo), FUN=length))


  #tipo1=length(unique(aggregate(checando$Group.1, by=list(checando$Group.1), FUN=length)$Group.1))
  #tipo2=length(unique(aggregate(checando$Group.2, by=list(checando$Group.1), FUN=length)$x))

  tipo1=length(unique(checando[,1]))#Mnemonico
  tipo2=length(unique(checando[,2]))#Tipos de preguntas
  tipo3=length(unique(checando[,3]))#Tipos de respuestas

  cat<-max(aggregate(checando$x, by=list(checando$Group.1), FUN=sum)$x)
  #tipo<-max(unique(c(tipo1,tipo2)))
  n_pre=length(unique(checando$Group.1))

  tipo<-if(tipo1==1 & tipo2==1){1} else if(tipo1==1 & tipo2>=2){1} else if(tipo1>=2 & tipo2>=2){1}else if(tipo1>=2 & tipo2==1){0}else{0}

  tipo_cat<-if(tipo1==1 & tipo2==1 & cat==2){0.8} else if(tipo1==1 & tipo2==1 & cat>2){0.6} else if(tipo1>=2 & tipo2>=2 & cat>2){0.4}else{0.4}
  tipo_cat

  df$cum_sum<- ave(df$Porcentaje, df$V_Mnemonicos, FUN = cumsum)
  m <- df[which.min(df$Porcentaje), ]

  df$Respuestas <- factor(df$Respuestas, levels = as.vector(unique(unlist(df$Respuestas))),ordered = TRUE)

  if (tipo==1){
    #====================================
    #Gráficos de barras, separadas
    #====================================
    p<-df %>%
      mutate(V_Mnemonicos = factor(V_Mnemonicos, levels = as.vector(unique(unlist(df$V_Mnemonicos))),ordered = FALSE)) %>%
      split(.$V_Mnemonicos) %>%
      purrr::imap(function(x, y) {
        mutate(x, Respuestas = reorder(Respuestas,Porcentaje)) %>%
          plot_ly(
            y = ~Respuestas,
            x = ~Porcentaje,
            #color = ~V_Mnemonicos,
            colors=col,
            type = "bar",
            text =~Text,#~paste(Porcentaje,"%",sep=""),
            textposition = ~txt_position,
            textfont=list(font_tex),
            orientation = 'h',
            name = ~Preguntas
          ) %>%
          layout(#xaxis = list(tickvals = (nrow(x) -1) / 2, ticktext = y),
            barmode = 'stack',
            hovermode = 'x',
            bargap = tipo_cat,
            title = list(text =titulo,y = 0.95, yanchor = "auto",font = font_title),
            margin = list( l = 0, r = 0, b = 0, t = 60),
            legend = list(traceorder = 'reversed',orientation = 'h',font = font_leg,traceorder= 'reversed'),  #,xanchor = "center",x = 0.5
            showlegend = TRUE,
            xaxis = list(title = "",tickvals=seq(0,100,10),
                         #tickvals=seq(0,ifelse(max(df$Porcentaje)<100, (max(df$Porcentaje)+10),100),10),
                         ticksuffix = "%",  range = c(0, 105),tickfont=font_tex),
            yaxis = list(title = "",showticklabels = TRUE,categoryorder = "trace")
          )%>%
          plotly::group_by(V_Mnemonicos)#%>%
        #layout(xaxis=list(title = "",tickvals=seq(0,100,20),
        #ticksuffix = "%",  range = c(0, 110),font=font_tex,showticklabels = FALSE))
      }
      ) %>%
      subplot(shareY = TRUE)
  }else{
    #====================================
    #Gráficos de barras, superpuestas
    #====================================
    df$Respuestas <- factor(df$Respuestas, levels = as.vector(unique(unlist(df$Respuestas))),ordered = FALSE)
    p <-
      plot_ly(
        df,
        y = ~  str_wrap(Preguntas,30),
        x = ~ Porcentaje,
        type = "bar",
        orientation = 'h',
        name = ~ Respuestas,
        #text = ~Text,
        text =as.factor(ifelse(df$Porcentaje >5, df$Text,"")),
        #textfont=font_tex,
        textposition ="auto", #~txt_position
        textangle = 0,
        hoverinfo = 'text',
        width = 800,
        height = 600
      ) %>%
      layout(barmode = 'stack',
             hovermode = 'x',
             bargap =ifelse(n_pre<=2,0.8,0.7),
             title = list(text =titulo,y = 0.95, yanchor = "auto",font = font_title),
             margin = list( l = 0, r = 0, b = 0, t = 60),
             legend = list(traceorder = 'reversed',orientation = 'h',font = font_leg),  #xanchor = "center",x = 0.5,
             xaxis = list(tickvals=seq(0,100,10), ticksuffix = "%",  range = c(0, 110),tickfont=font_tex,
                          title = "",showticklabels = TRUE,categoryorder = "total descending"),
             yaxis = list(title = "",showticklabels = TRUE,categoryorder = "trace"))%>%
      htmlwidgets::onRender(unique(df$Respuestas))#%>%
    # p%>%add_annotations(x = m$cum_sum,y =0.5,text = m$Text,xref = "x",yref = "y",showarrow = FALSE)

  }

}


#==================================================================
#Función para los gráficos de barra agrupados, con diferentes categorías
#==================================================================
plot_indica<-function(df,tipo_grafico,Tit,Subt){

  plot_type<-tipo_grafico

  if (Subt=="General"){
    titulo<-Tit
  }else{
    titulo<-trim(paste(Tit,"<br> <sup>",Subt,"</sup>",sep=""))
  }


  colores<-as.vector(unlist(unique(proc_color_table$color)))
  font_title<-list(family = "sans-serif",size = 15,color = "black")
  font_yaxis<-list(family = "sans-serif",size = 12,color = "black")
  font_xaxis<-list(family = "sans-serif",size = 12,color = "black")
  font_leg  <-list(family = "sans-serif",size =  10,color = "black")
  font_tex  <-list(family = "sans-serif",size = 8,color = "black")

  col=sample(colores, length(unique(df$Preguntas)))
  col2=sample(colores, length(unique(df$Preguntas)))
  col2<-ifelse(col==col2,sample(colores, length(unique(df$Preguntas))),col2)

  #df$Text<-ifelse(df$Porcentaje!=0,paste(df$Porcentaje,"%",sep=""),"")
  df$txt_position<-ifelse(df$Porcentaje<=20,"outside","inside")

  n_pre=unique(df$N_preg)

  #====================================
  #Gráficos de barras
  #====================================
  if (plot_type== "bar_h"){

    p<-plot_ly(df,x=~df$Porcentaje,y=~factor(df$Preguntas),
               color=~factor(df$Preguntas),
               colors =col,
               type = "bar",
               text =~df$Text,
               textposition = 'outside',
               textfont=list(font_tex),
               width = 1200, height = 600,
               orientation = 'h',
               marker = list(line = list(color = col, width = 1))) %>%
      #add_text(text=~df$Text, hoverinfo="text", textposition = 'top', showlegend = FALSE,textfont=list(family = "sans-serif",size=12, color="black"))%>%
      layout(hovermode = 'x',
             bargap = ifelse(n_pre<=3,0.41,0.4),
             title = list(text =titulo,y = 0.95, yanchor = "auto",font = font_title),
             margin = list( l = 0, r = 0, b = 0, t = 60),
             #legend = list(orientation = 'h',font = font_leg),  #,xanchor = "center",x = 0.5
             legend = list(traceorder = 'reversed',orientation = 'h',font = font_leg),
             #xaxis = list(tickvals=seq(0,ifelse(max(df$Porcentaje)<100, (max(df$Porcentaje)+10),100),10),
             xaxis = list(title = "", tickvals=seq(0,100,10),ticksuffix = "",  range = c(0, 110),tickfont=font_leg),
             yaxis = list(title = "",showticklabels = FALSE,categoryorder = "trace")
      )

  }
    #====================================
    #Gráficos de Gauge
    #====================================
    else if (plot_type== "gauge"){
      plot_ly(
        domain = list(x=c(0,100),y=c(0,100)),
        value=df$Porcentaje,
        title=list(text=titulo),
        type="indicator",
        mode="gauge+number+delta",
        delta=list(reference=100),
        gauge=list(
          axis=list(range=list(NULL,100),tickwidth=4,tickcolor="darkblue"),
          bar=list(color=col,thickness=0.4,line = list(width = 1)),
          steps=list(
            list(range=c(0,25),color=col2),
            list(range=c(25,50),color=col2),
            list(range=c(50,75),color=col2),
            list(range=c(75,100),color=col2)),
          threshold=list(
            line=list(color="red",width=2),
            thickness=0.5,
            value=df$Porcentaje)
        )
      )%>%
        layout(
          margin=list(l=20,r=60,b=0,t=60),
          paper_bgcolor = "white",
          font=font_title
        )
    }

  }


#==================================================================
#Función para crear el corpues, para el análisis de texto
#==================================================================
Corpus<-function(x, lang="spanish", mystopwords=topwords,textStemming=FALSE,textLemmatization=FALSE,n_grams){
  #texto<-list_text$texto
  x<-str_trim(stri_trans_general(x, id="Latin-ASCII")) #Covertir a minusculas
  text <- VCorpus(VectorSource(x)) #Crear text
  text<- tm_map(text, content_transformer(tolower)) #Convertir minusculas
  text<- tm_map(text, stripWhitespace) # Quitar doble espacio
  text<- tm_map(text, removePunctuation,preserve_intra_word_contractions = FALSE,
                  preserve_intra_word_dashes = TRUE) # Quitar puntuaciones
  text<- tm_map(text, removeNumbers) # Quitar números

  # Función para remover otros signos
  text_preprocessing<- function(x) {
    gsub('http\\S+\\s*','',x) # quitar URL
    gsub('#\\S+','',x) # quitar hashtags
    gsub('[[:cntrl:]]','',x) # quitar espacios
    gsub("^[[:space:]]*","",x) # Quitar espacion en blanco al inicio
    gsub("[[:space:]]*$","",x) # Quitar espacion en blanco al final
    gsub(' +', ' ', x) # Quitar otro espacion en blancos
    gsub("http[^[:space:]]*", " ", x) #Quitar links
    gsub('\\b+RT', " ", x) #Quitar retweets
    gsub('@\\S+', " ", x)#Quitar mentions
    gsub('#\\S+', " ", x) #Quitar hashtags
  }
  # Aplicar función
  text<-tm_map(text,text_preprocessing)

  text<- tm_map(text, removeWords, stopwords(lang))#Eliminar palbras automático
  if(!is.null(mystopwords)) text <- tm_map(text, removeWords, topwords)#Eliminar palbras vacias de una lista cargada

  if(textStemming) text <- tm_map(text, stemDocument)#Stemming

  if(textLemmatization) text <- tm_map(text, content_transformer(lemmatize_strings))#Lemmatization

  text<- tm_map(text, stripWhitespace)
  corpus <- tm_map(text, PlainTextDocument)

  BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = n_grams, max = n_grams))

  #tdm <- TermDocumentMatrix(SimpleCorpus(VectorSource(unlist(lapply(corpus, as.character)))))
  tdm <- TermDocumentMatrix(corpus,control = list(tokenize = BigramTokenizer))


  m <- as.matrix(tdm)
  v <- sort(rowSums(m),decreasing=TRUE)
  freq <- data.frame(word = names(v),freq=v)

  return(freq)
}



#==================================================================
#Función encontrar diferencia en dos vectores
#==================================================================
diferencia <- function(str1, str2) {
  # Split strings into words
  words1 <- unlist(strsplit(str1, " "))
  words2 <- unlist(strsplit(str2, " "))

  # Find differences
  diff1 <- setdiff(words1, words2)
  diff2 <- setdiff(words2, words1)

  # Combine differences
  differences <- paste(c(diff1, diff2), collapse = " ")
  return(differences)
}

#==================================================================
#Función para remover los espacios alrrededor de la imagen
#==================================================================
library(magick)

trim_space<-function(carpeta,formato){
  #if (missing(picture)==T){
    x=list.files(carpeta)
    lista_graficas=x[grep(x,pattern=formato)]
  #}
  #else {lista_graficas=paste(picture,formato,sep="")}

  for(i in 1:length(lista_graficas)){
    path=paste(carpeta,"\\",lista_graficas[i],sep='')
    im=image_read(path)
    im=image_trim(im)
    image_write(image=im,path)
    print(paste('Completado: ',i,' de ',length(lista_graficas),sep=''))
  }
}


#==================================================================
#Función para unir dos tablas mediante string fuzzy
#==================================================================

joinleft_fuzzy<-function(df1,df2,vars_macht,var_select){
  stringdist_left_join(df1, df2,
                       by = vars_macht,
                       method = "jw",
                       p = 0.15,
                       distance_col = "distance",
                       ignore_case = TRUE,
                       max_dist = 0.01) |>
    subset(select = c(var_select))
}


#==================================================================
#Función para extraer multiples hojas de excel
#==================================================================
library(readxl)
multiplesheets <- function(fname,hojas,rango) {

  # getting info about all excel sheets
  sheets <- readxl::excel_sheets(fname)
  sheets<-sheets[hojas]
  tibble <- lapply(sheets, function(x)
    readxl::read_excel(fname, sheet = x, col_names = T,range=rango))
  data_frame <- lapply(tibble, as.data.frame)

  # assigning names to data frames
  names(data_frame) <- sheets
  #return(data_frame)
}



#---------------------------------------------------------------------------------------
#Función para exportar xlsx con formato, usando la librería "openxlsx"
#---------------------------------------------------------------------------------------
library(openxlsx2)
library(openxlsx)

#Style:https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_tableStyle_topic_ID0EFIO6.html


worksheet_export1<-function(df,file_xlsx,sheets,Style){

  df_list <- list()
  df_list[[1]] <- df

  width_col<-as.data.frame(t(data.frame(lapply(df, function(x) max(nchar(x))))))
  colnames(width_col)<-"ncaracter"
  width_col$ncaracter<-as.numeric(width_col$ncaracter)

  width_col<-width_col %>%
    mutate(ancho = case_when(ncaracter<=10 ~ 15,
                             ncaracter>10 & ncaracter<50 ~ 25,
                             ncaracter>=50 & ncaracter<100 ~ 50,
                             ncaracter>=100 ~ 75,
                             TRUE ~ 15)
    )

  wb <- createWorkbook()

  for (k in 1:length(sheets)){

    addWorksheet(wb, sheet = sheets[k])
    writeDataTable(wb,
                   sheets[k],
                   data.frame(df_list[k])
                   #,tableStyle = Style
                   )

    #modifyBaseFont(wb, fontSize = 11, fontName = "Arial")
    #setColWidths(wb,sheets[k],cols = 1:ncol(data.frame(df_list[k])),widths = "auto")
    setColWidths(wb,sheets[k],cols = 1:ncol(data.frame(df_list[k])),widths = as.vector(width_col$ancho))#Ancho de columnas
    setRowHeights(wb, sheets[k],rows = 2:nrow(data.frame(df_list[k])),heights = 30)#Ancho de las hileras

    headerStyle <- createStyle(fontSize=11,fontColour="white",fontName = "Arial",fgFill=Style,
                               halign="center",valign="center",textDecoration="italic",
                               borderColour = "black",border = "TopBottom",borderStyle = "double")#Estilo de encabezado

    centerWrapStyle <- createStyle(halign = "center", valign = "center", wrapText = TRUE)#Ajuste de texto, centro
    leftAlignStyle <- createStyle(halign = "left", valign = "center",wrapText = TRUE)#Ajuste de texto, izquierdo
    rightAlignStyle <- createStyle(halign = "right", valign = "center",wrapText = TRUE)#Ajuste de texto, derecho
    border <- createStyle(border = "TopBottomLeftRight", borderStyle = "dashed")# Estilos de bordes
    grayStyle <- createStyle(fgFill = "#D3D3D3",halign = "left", valign = "center",wrapText = TRUE,border = "TopBottomLeftRight", borderStyle = "dashed")  # Light gray
    whiteStyle <- createStyle(fgFill = "#FFFFFF",halign = "left", valign = "center",wrapText = TRUE,border = "TopBottomLeftRight", borderStyle = "dashed")  # White

    #Aplicar todos los estilos
    addStyle(wb, sheet = sheets[k], style = headerStyle, rows = 1, cols = 1:ncol(data.frame(df_list[k])), gridExpand = TRUE)
    addStyle(wb, sheet = sheets[k], style = centerWrapStyle, rows = 2:nrow(data.frame(df_list[k])),cols = 1:ncol(data.frame(df_list[k])), gridExpand = TRUE)
    addStyle(wb, sheet = sheets[k], style = leftAlignStyle, rows = 2:nrow(data.frame(df_list[k])),cols = 1:ncol(data.frame(df_list[k])), gridExpand = TRUE)
    addStyle(wb, sheet = sheets[k], style = border, rows = 2:nrow(data.frame(df_list[k])),cols = 1:ncol(data.frame(df_list[k])), gridExpand = TRUE) # Punteado

    for (i in 2:(nrow(data.frame(df_list[k])) + 1)) {  # Rows 3 to nrow(data) + 2 (header is in row 2)
      if ((i %% 2) == 0) {

        # Apply white background to odd-numbered rows
        addStyle(wb, sheet = sheets[k], style = whiteStyle, rows = i, cols = 1:ncol(data.frame(df_list[k])), gridExpand = TRUE)
      } else {
        # Apply gray background to even-numbered rows
        addStyle(wb, sheet = sheets[k], style = grayStyle, rows = i, cols = 1:ncol(data.frame(df_list[k])), gridExpand = TRUE)
      }
    }

  }
  saveWorkbook(wb,file_xlsx,overwrite = TRUE)

}

#---------------------------------------------------------------------------------------
#Se agrega alguna imagen al inicio del formato
#---------------------------------------------------------------------------------------
worksheet_export2<-function(df,file_xlsx,sheets,fila,columna,Style,imagen,Titulos){

  wb <- createWorkbook()

  for (k in 1:length(sheets)){

    addWorksheet(wb, sheet = sheets[k])
    modifyBaseFont(wb, fontSize = 11, fontName = "Arial")

    writeDataTable(wb,
                   sheets[k],
                   data.frame(df[k]),
                   startRow = fila,
                   startCol = columna,
                   tableStyle = Style)

    #Set column widths auto
    setColWidths(wb,sheets[k],cols = 1:ncol(data.frame(df[k])),widths = "auto")

    #Set row widths auto
    #setRowHeights(wb, sheets[k], rows = 7:nrow(data.frame(df[k])), heights = 40)

    #Create a header style
    headerStyle <- createStyle(fontColour="white",fgFill="blue",halign="left",valign="center",textDecoration="bold")

    if (length(imagen)!=0 & length(Titulos)!=0) {

      #Create a body style
      #bodyStyle <- createStyle(border = "TopBottom", borderColour = "#4F81BD")
      #addStyle(wb, sheet = sheets[k], bodyStyle, rows = 7:nrow(data.frame(df[k])), cols = 1:ncol(data.frame(df[k])), gridExpand = TRUE)

      #Insert titles
      mergeCells(wb, sheets[k], rows=2,cols= 4:6)
      writeData(wb, sheets[k], Titulos[1], startCol = 4, startRow = 2)

      mergeCells(wb, sheets[k], rows=3,cols= 4:6)
      writeData(wb, sheets[k],Titulos[2], startCol = 4, startRow = 3)
      #addStyle(wb = wb, sheet = sheets[k], cols = 4L, rows = 1:4,style = createStyle(halign = 'right'))

      # Insert the image into the worksheet
      img_path <- imagen
      insertImage(wb, sheet = sheets[k], file = img_path, width = 1.8, height = 1, startRow = 1, startCol = 2)
    }


  }
  saveWorkbook(wb,file_xlsx,overwrite = TRUE)

}


