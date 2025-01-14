##################################################################
# Elabora: Germán Gáldamez                                       #
# Fecha: 01 Marzo 2024                                           #
# Evento: Evaluación 2025                                        #
# Tratamiento                                                      #
##################################################################

#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
#1. COMIENZA DECLARANDO EL DIRECTORIO DE TRABAJO
#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&


  #Limpieza de memoria
  rm(list=ls())


  #Establecer ruta, este puede cambiar
  Raiz<-c("C:/Users/german.galdamez/OneDrive - INEGI/EVALUACION_2024")

  #Leer todas las funciones que seran usadas
  source(paste(Raiz,"SCRIPTS_R","0_Funciones.R",sep="/"))

  #En cado de fallar Java, se puede instalar en C https://www.java.com/en/download/

  ##################################################################
  # Estructura de carpetas y archivos                              #
  ##################################################################

  #Ruta donde se tiene los insumos
  library("stringi")
  Direct<-paste(Raiz,"TRATAMIENTO",sep="/")
  setwd(Direct)
  getwd()

  #Crear la estructura de carpeta, si ya existe, solo creará las que no se tengan
  Etapa<-"01_SIMULACION"
  estructura_carpeta(Direct,Etapa)

  #Lista de carpetas, estás son las etapas de la evaluación
  Estructura<-list.dirs(Direct,recursive = F)
  n<-str_count(Estructura[1],"/")

  dir_list <- data.frame(Direct=list.dirs(Direct,recursive = F))
  dir_list<-cbind(dir_list,str_split_fixed(dir_list$Direct, '/', n=n+1))
  dir_list<-dir_list[,c(1,6,7,8)]
  colnames(dir_list)<-c("PAHT","PROYECTO","ACTIVIDAD","FASE")
  carpetas<-dir_list[,4]

 #itera según el númreo de subprocesos, solo se ha trabajado en "00_CATI" y "01_SIMULACION"
  FASES<-str_subset(as.vector(unique(unlist(carpetas))),pattern = fixed("_"))[2]

#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
#2. COMIENZA EL TRATAMIENTO DE LA INFORMACIÓN
#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

  #----------------------------------------------------------------
  #Se extrae las preguntas y mnemonicos de los requerimientos
  #----------------------------------------------------------------

  Req<-list.files(paste(Direct,FASES,"CATALAGO",sep="/")) #cambiar FASE,por carpeta 01_SIMULACION
  Req<-Req[str_detect(Req,"REQUERIMIENTO")==T]

  REQUERIMIENTO<-read_excel(paste(Direct,FASES,"CATALAGO",Req,sep="/"),sheet = "Requerimiento",range="B9:T100")
  columnas<-colnames(REQUERIMIENTO)
  columnas = gsub(" ","_",stri_trans_general(columnas, id="Latin-ASCII"))
  colnames(REQUERIMIENTO)<-columnas
  REQUERIMIENTO<-elimineempty_rowcol(REQUERIMIENTO)
  REQUERIMIENTO<-REQUERIMIENTO[!is.na(REQUERIMIENTO$MNEMONICO),]
  REQUERIMIENTO<-select(REQUERIMIENTO, -c("INSTRUCCIONES_PARTICULARES","PERIODO_DE_APLICACION"))

  REQUERIMIENTO<-data.frame(REQUERIMIENTO, REQUERIMIENTO=gsub(".xlsx","",Req))
  word<-c("Otra","Otras","Otro","Otros")
  REQUERIMIENTO$OPCIONES_DE_RESPUESTA<-gsub(paste(word, collapse = "|"), "Otras", REQUERIMIENTO$OPCIONES_DE_RESPUESTA)

  columnas=gsub("  "," ",trat_strint(colnames(REQUERIMIENTO))) #trat_strint() Es una función que elimina cualquier caracter especial
  colnames(REQUERIMIENTO)<-columnas
  REQUERIMIENTO <- REQUERIMIENTO[order(REQUERIMIENTO$MNEMONICO),]

  #----------------------------------------------------------------
  #Crear o Incorporar las preguntas a un banco
  #----------------------------------------------------------------

  # write.xlsxREQUERIMIENTO, file=paste(Direct,FASES,"RESULTADO","BASE_REQUERIMIENTO.xlsx",sep="/"),
  #sheetName="REQUERIMIENTO",col.names=TRUE, row.names=F,append=TRUE)


  ##################################################################
  # Lectura(importar) las tablas de la evaluación                  #
  ##################################################################

  #------------------------------------------------------------------
  #Identificar las tablas y sus claves
  #------------------------------------------------------------------
  list_tab<-list.files(paste(Direct,FASES,"TABLAS",sep="/"))
  clave_tab<-str_extract(list_tab, "\\([^()]*\\d[^()]*\\)|\\([^()]*\\d[^()]*\\)*$")
  clave_tab<-as.vector(unlist(regmatches(clave_tab,gregexpr("(?<=\\().*?(?=\\))", clave_tab, perl=TRUE))))
  #clave_tab<-clave_tab[startsWith(clave_tab,"CAP_")]
  clave_tab<-str_subset(clave_tab,fixed("_"))

  list_tab<-list_tab[str_detect(list_tab, paste(clave_tab,collapse = "|"))==T]

  list_tab<-list_tab #solo se trata autoenumeracion

  library(readxl)
  library(writexl)
  #df.list <- lapply(paste(Direct_FASE,"TABLAS",list_tab,sep="/"), read_excel)

  RESUL<-paste(Direct,FASES,"RESULTADO",sep="/")
  file=paste(Direct,FASES,"TABLAS",list_tab,sep="/")

  #------------------------------------------------------------------
  #Para leer achivos en excel y almacenarlos en una lista
  #------------------------------------------------------------------

  df_list<-read_file_xlsx(file[3],1)
  names(df_list)<-clave_tab[3]

  #------------------------------------------------------------------
  #Para leer achivos en csv y almacenarlos en una lista(activar si se tienen)
  #------------------------------------------------------------------
  #df_list<-read_file_csv(file)
  #names(df_list)<-clave_tab

  #------------------------------------------------------------------
  #Almacenar las tablas en una lista
  #------------------------------------------------------------------
  lista_tablas<-data.frame(
    Directorio=paste(Direct,FASES,"TABLAS",sep="/"),
    Tabla=list_tab,
    Clave=clave_tab
  )
  lista_tablas <- lista_tablas[order(lista_tablas$Clave),]


  ##################################################################
  # SE EMPIEZA A TRABAJAR CON LAS TABLAS
  ##################################################################

    #----------------------------------------------------------------
    #Se extrae las preguntas y mnemonicos de cada tabla, se aplica un for{}
    #----------------------------------------------------------------

    Tablas<-as.vector(unlist(lista_tablas$Clave))[3]

    Codificadas<-list()

        #for(Tab in Tablas){

        Tab<-Tablas

        tab<-df_list[[Tab]]
        print(unique(tab$archivo))
        #tab<-elimineempty_rowcol(as.data.frame(tab))
        #colnames(tab)<-str_replace_all(colnames(tab),"!other","Otras")
        #index=which(str_detect(colnames(tab),'!other')==T)

        tab$GE_02_04_04_0005_01<-"Manuel Gerardo Cossí Reyes"
        tab$GE_02_04_04_0005_02<-"Jorge Alejandro Reyes Eguren"
        tab$GE_02_04_04_0005_03<-"Juan Ramón Mena"
        tab$GE_02_04_04_0005_04<-"Maritza González Huitrón"
        tab$GE_02_04_04_0005_05<-"Laura Noemí Guzmán Moreno"
        tab$GE_02_04_04_0005_06<-"Cecilia Martinez Serrano"
        tab$GE_02_04_04_0005_07<-"María Fernanda Salina Álvarez"


        colnames(tab)<-gsub("\\[|\\]", "",  colnames(tab))
        colnames(tab)<-str_replace_all(colnames(tab),"!other","Otras")
        colnames(tab)<-str_replace_all(colnames(tab),"Otro:","O")

        library("stringi")

        preg<-data.frame(Preguntas=colnames(as.data.frame(tab)))
        preg$No<-1:nrow(preg)
        preg<-preg%>% tidyr::separate(Preguntas, c("Cons","Cols"), sep = '->')
        #preg$Preguntas_c<-str_extract(preg$Preguntas, "\\([^()]*\\)|[^()]+")
        preg<-preg%>% mutate(Preguntas = str_extract(Cols, "\\([^()]*\\)|[^()]+")) #usar https://regex101.com/r/o1A49R/1/
        preg$No_preg<-ifelse(str_detect(preg$Cons,"(?=.*[0-9]).*")==T,str_sub(preg$Cons,1,3),NA)
        preg<-preg%>% mutate(Mnemonicos = str_extract(Cols, "\\([^()]*\\d[^()]*\\)|\\([^()]*\\d[^()]*\\)*$")) #usar https://regex101.com/r/o1A49R/1/
        preg$Mnemonicos<-ifelse(str_detect(preg$Cons,"(?=.*[0-9]).*")==T & is.na(preg$Mnemonicos),str_sub(preg$Cons,5,20),preg$Mnemonicos)
        preg$No_fac<-ifelse(str_detect(preg$Cons,"(?=.*[0-9]).*")==T & length(preg$Cons)>20,str_sub(preg$Cons,22,23),NA)

        preg$Preguntas<-ifelse(is.na(preg$Preguntas),preg$Cons,preg$Preguntas)
        preg$Mnemonicos<-ifelse(is.na(preg$Mnemonicos),preg$Cons,preg$Mnemonicos)



        #columnas<-colnames(as.data.frame(tab))
        #preg<-str_extract_all(preg$Preguntas, "\\([^()]*\\)|[^()]+")
        #preg<-as.vector(unlist(preg))
        #preg<-data.frame(preg=columnas)%>% mutate(Preguntas = str_extract(preg, "\\([^()]*\\)|[^()]+"))
        #preg<-preg%>% mutate(Mnemonicos = str_extract(preg, "(\\(.*?\\)\\*?)"))
        #preg<-preg%>% mutate(Mnemonicos = str_extract(preg, "\\([^()]*\\d[^()]*\\)|\\([^()]*\\d[^()]*\\)*$")) #usar https://regex101.com/r/o1A49R/1/
        #preg$Preguntas<-replace(preg$Preguntas,preg$Preguntas %in% !is.na(preg$Mnemonicos),"")
        #preg<-df_col[,c(3,5,4,6,7)]

        preg$Mnemonicos<-gsub(" ","_",stri_trans_general(preg$Mnemonicos,"Latin-ASCII"))
        preg$Mnemonicos<-gsub("[][!#%()*,.:;<=>@^`|~.{}]"," ",preg$Mnemonicos)

        #preg$Mnemonicos<-ifelse(is.na(preg$Mnemonicos),gsub(" ","_",stri_trans_general(preg$Preguntas,"Latin-ASCII")),gsub("[][!#%()*,.:;<=>@^`|~.{}]"," ",preg$Mnemonicos))


        preg$Preguntas<-trat_strint(preg$Preguntas)
        preg$Mnemonicos<-trat_strint(preg$Mnemonicos)
        preg$No_fac[preg$No_fac==""] <- NA

        preg$Dirigido<-ifelse(str_detect(preg$Preguntas,"facilitadora")==T,"Facilitador","Grupal")
        preg$Dirigido<-ifelse(str_detect(preg$Mnemonicos,"GE_02_04_04_0015")==T,"Facilitador",preg$Dirigido)

        library(tidyr)
        library(dplyr)
        library(zoo)
        preg<-preg %>% mutate(cv_fac = ifelse(preg$Dirigido=="Facilitador",na.locf0(No_fac),No_fac))
        preg$cv_fac[is.na(preg$cv_fac)]<-"00"
        preg$Dirigido<-ifelse(preg$cv_fac!="00","Facilitador","Grupal")

        #............................................................
        # A D I C I O N A L
        #............................................................
        preg<-data.frame(Preguntas=colnames(as.data.frame(tab)))
        preg$No<-1:nrow(preg)
        preg$Mnemonicos<-str_sub(preg$Preguntas,1,16)
        preg$No_fac<-str_sub(preg$Preguntas,18,19)
        preg$No_fac[preg$No_fac==""] <- NA
        preg$Dirigido<-ifelse(!is.na(preg$No_fac),"Facilitador","Grupal")
        preg$Dirigido<-ifelse(str_detect(preg$Mnemonicos,"GE_02_04_04_0015")==T,"Facilitador",preg$Dirigido)

        preg<-preg %>% mutate(cv_fac = ifelse(preg$Dirigido=="Facilitador",na.locf0(No_fac),No_fac))
        preg$cv_fac[is.na(preg$cv_fac)]<-"00"
        preg$Dirigido<-ifelse(preg$cv_fac!="00","Facilitador","Grupal")

        #----------------------------------------------------------------
        #Se realiza macht con las preguntas y mnemonicos del catálago
        #----------------------------------------------------------------

        library(fuzzyjoin)
        library(dplyr)
        library(rlang)
        library(stringdist)
        library(evaluate)

        #preg$llave<-str_replace_all(preg$Preguntas, regex("\\s*"), "")
        #catalago$llave<-str_replace_all(catalago$Preguntas,regex("\\s*"), "")

        #compara_preg<-preg %>%
          #stringdist_left_join(catalago,method="lv", max_dist=5) %>%
          #mutate(lv_dist=stringdist(llave.x,llave.y, method="lv"))%>%
          #select(Preguntas,Mnemonicos,Preguntas_c,Mnemonicos_c,Respuestas,Clave,Objetivo,lv_dist)%>%
          #filter(lv_dist<20)%>%
        #distinct()

        #write.xlsx(compara_preg,paste(Direct,FASES,"RESULTADO","compara.xlsx",sep="/"),sheetName="preguntas",row.names=FALSE)


        REQUERIMIENTO$Mnemonicos<-REQUERIMIENTO$MNEMONICO
        preg_catalago <- merge(preg, REQUERIMIENTO, by = "Mnemonicos", all.x = TRUE)
        preg_catalago<-preg_catalago[order(preg_catalago$No),]

        preg_catalago$TIPO_DE_RESPUESTA<-ifelse(preg_catalago$Preguntas=="O","Abierta",preg_catalago$TIPO_DE_RESPUESTA)
        preg_catalago$OPCIONES_DE_RESPUESTA<-ifelse(preg_catalago$Preguntas=="O","Abierta",preg_catalago$OPCIONES_DE_RESPUESTA)
        preg_catalago$Mnemonicos<-ifelse(preg_catalago$Preguntas=="O",paste0(preg_catalago$Mnemonicos,"_O"),preg_catalago$Mnemonicos)

        preg_catalago$MNEMONICO<-ifelse(is.na(preg_catalago$MNEMONICO),preg_catalago$Mnemonicos,preg_catalago$MNEMONICO)
        preg_catalago$TIPO_DE_PREGUNTA<-ifelse(is.na(preg_catalago$TIPO_DE_PREGUNTA),"Control",preg_catalago$TIPO_DE_PREGUNTA)
        preg_catalago$PREGUNTAS<-ifelse(is.na(preg_catalago$PREGUNTAS),preg_catalago$Preguntas,preg_catalago$PREGUNTAS)
        preg_catalago <- preg_catalago[order(preg_catalago$No),]


        ##########################################################################################################################################
        #Se Combina las multirespuestas separado por columnas(Caso especial), son tablas generados por la PICAT
        ##########################################################################################################################################

        #Este apartado fue solo para "00_CATI" las tablas se descarga de la PICAT, en 01_SIMULACION no se hace la union de respuesta ya que las multirespuesta
        #se enceuentra en una sola columna, se omite esta rutina.

        list_conc<-preg_catalago[preg_catalago$TIPO_DE_RESPUESTA=="Opción múltiple (Abierta)",]
        list_conc<-list_conc[!is.na(list_conc$TIPO_DE_RESPUESTA),]

        list_conc <- list_conc[order(list_conc$No),]
        list_conc<-list_conc[is.na(list_conc$No_fac),] #Quitar los facilitadores
        unicos<-unique(list_conc$Mnemonicos)

        dat_concat <- list()

        for(i in 1:length(unicos)){
          #i<-1
          vec<-as.vector(list_conc[list_conc$Mnemonicos==unicos[i],"No"])
          resp<-list_conc[list_conc$Mnemonicos==unicos[i],"Preguntas"]

          dat<-tab[,c(vec)]

          for (j in 1:length(vec)){
            #resp<-as.vector(unlist(strsplit(paste(1,as.vector(list_conc[list_conc$Mnemonicos==unicos[i],"Preguntas"]),sep="=",collapse = "/"),"/")))

            vector<-as.character(unlist(dat[,j]))
            vector<- str_replace_all(vector,"1",resp[j])
            dat[,j]<-vector
          }

          #dat<-dat%>% unite( col=unicos[i], colnames(dat), sep=';')
          dat[dat==0]<-NA
          Combina<-data.frame(Combina=apply(dat,1, function(x) paste0(na.omit(x), collapse = ";")))
          names(Combina) <-unicos[i]
          dat<-cbind(dat,Combina)
          dat_concat[[i]] <-Combina
          #tab<-cbind(tab,Combina)
        }

        df_concat<-do.call(cbind, unique(dat_concat))
        ##########################################################################################################################################


        ##########################################################################################################################################
        # SE CREA UNA LISTA DE LAS PREGUNTAS, SUS RESPUESTAS Y POSIBLES VALORES, QUE SE USA PARA EL REEMPLAZO EN LA TABLA
        ##########################################################################################################################################

        #----------------------------------------------------------------
        #Extrae valores de las preguntas
        #----------------------------------------------------------------
        Preguntas<-preg_catalago[,c("No","MNEMONICO","PREGUNTAS","OPCIONES_DE_RESPUESTA","TIPO_DE_RESPUESTA","cv_fac")]
        rename<-c("No","Mnemonicos","Preguntas","Respuestas","Tipo","cv_fac")
        colnames(Preguntas)<-rename
        Preguntas$Mnemonicos<-stri_trim_both(Preguntas$Mnemonicos)
        Preguntas$Respuestas<-stri_trim_both(Preguntas$Respuestas)


        #setDT(FD)[Respuestas %in% c("1…5"), Respuestas_c := gsub(",",";",stri_reverse(toString(str_sub(Respuestas,1,1):substrRight(Respuestas,1))))]
        #FD$Preguntas_c<-NA
        Preguntas[which(Preguntas$Respuestas %in%"1…5"),c("Respuestas_c")] <- paste(eval(parse(text = "1:5")),collapse = ";")
        Preguntas$Respuestas_c<-ifelse(is.na(Preguntas$Respuestas_c),Preguntas$Respuestas,Preguntas$Respuestas_c)
        Preguntas$No_Value=stringr::str_count(Preguntas$Respuestas_c, ';')+1

        '%!in%' = Negate('%in%')

        index=which(names(Preguntas) %in% c('No','Mnemonicos','Preguntas',"Respuestas_c","Tipo","cv_fac","No_Value"))
        Preguntas=Preguntas %>% filter(Preguntas!="NA" & Mnemonicos!="NA" & Respuestas_c %!in% c('NA','Abierta'))%>%
          distinct(No,Mnemonicos,.keep_all= TRUE) %>% select_at(index)

        #index=which(names(Preguntas) %in% c('No',"Mnemonicos","Preguntas"))
        #Mnemonicos=Preguntas %>% filter(Preguntas!="NA" & Mnemonicos!="NA" & Respuestas %!in% c('NA','Abierta'))%>%
          #distinct(No,Mnemonicos,.keep_all= TRUE) %>% select_at(index)
        #MNEMNONICO_UNICO=Mnemonicos %>% select(Mnemonicos) %>% unlist() %>% as.character() %>% unique()


        #VAL_COD<-Preguntas%>% separate_longer_delim(c(Respuestas_c, Clave), delim = ";")

        VAL_COD<-Preguntas%>% separate_longer_delim(Respuestas_c, delim = ";")
        VAL_COD= VAL_COD%>% tidyr::separate(Respuestas_c, c("Respuestas","Codigo"), sep = '=')
        VAL_COD$Respuestas[VAL_COD$Respuestas==""] <- NA
        VAL_COD<-VAL_COD[!is.na(VAL_COD$Respuestas),]
        VAL_COD$Codigo<-ifelse(VAL_COD$Tipo=="Escala" & is.na(VAL_COD$Codigo),VAL_COD$Respuestas,VAL_COD$Codigo)
        VAL_COD$Respuestas<-str_replace_all(VAL_COD$Respuestas, "[\r\n]" , "")
        VAL_COD[is.na(VAL_COD$Codigo),"Codigo"]<-"1"

        VAL_COD <-VAL_COD%>%
          group_by(Mnemonicos,cv_fac) %>%
          mutate(max = max(as.numeric(Codigo), na.rm=TRUE))

        #VAL_COD$max <- ave(VAL_COD$Codigo, paste(VAL_COD$Mnemonicos,VAL_COD$cv_fac,sep="_"), FUN = max) #Otra opción encontrar el maximo
        #VAL_COD$max<-ifelse(VAL_COD$Tipo=="Opción múltiple (Abierta)",VAL_COD$No_Value,VAL_COD$max)

        VAL_COD$max<-ifelse(is.na(VAL_COD$max),VAL_COD$No_Value,VAL_COD$max)

        #VAL_COD<-VAL_COD[,c(1,2,6,3,5,7,8,4)]


        setDT(VAL_COD)[Tipo=="Escala" & is.na(Codigo), Codigo := Respuestas]#
        #setDT(VAL_COD)[Tipo=="Dicotómica", Codigo := Respuestas] #
        #setDT(VAL_COD)[Respuestas=="Sí" , Codigo := "1"] #
        #setDT(VAL_COD)[Respuestas=="No" , Codigo := "0"] #
        #setDT(VAL_COD)[Tipo=="Multirespuestas" , Codigo := "1"] #

        VAL_COD <- VAL_COD[order(VAL_COD$No),]

        VAL_COD$Clave<-as.numeric(VAL_COD$Codigo)/as.numeric(VAL_COD$max)

        VAL_COD<-VAL_COD %>% distinct(Mnemonicos,cv_fac,Respuestas, .keep_all = TRUE)
        VAL_COD<-data.frame(VAL_COD)

        #setDT(VAL_COD)[!is.na(No_fac), Mnemonicos_ := paste0(Mnemonicos,"_",No_fac)]
        #setDT(VAL_COD)[length(Mnemonicos_)>18, Mnemonicos_ := substrRight(Mnemonicos_,10)]


        #VAL_COD<-VAL_COD[,c("Mnemonicos","Preguntas_c","Respuestas","Codigo","Clave","Objetivo")]

        #library(plyr)
        #VAL_COD_C<-ddply(VAL_COD, .(Mnemonicos), summarize, resp=paste(Respuestas, collapse=","),cod=paste(Codigo, collapse=","))



        ##########################################################################################################################################
        #SE REALIZA LA RUTINA DE VALIDAR LOS VALORES DE LA TABLA VS LOS VALORES DEL REQUERIMIENTO
        #ESTE ES OPCIONAL, SI ES QUE SE QUIERE VALIDAR LAS TABLAS.
        ##########################################################################################################################################

        library(plyr); library(dplyr)

        #-------------------------------------------------------------------------
        #Se obtiene las frecuencias de respuestas, se almacena en el DataFrame "respuestas"
        #-------------------------------------------------------------------------

        preg_catalago<-preg_catalago[preg_catalago$Mnemonicos!="archivo",]
        vars <- preg_catalago[preg_catalago$TIPO_DE_RESPUESTA!="Opción múltiple (Abierta)",2]

        mylist = vector("list",length(vars))

        for(i in 1: length(vars)){
          #i<-3
          mylist[[i]] <- data.frame(V_Mnemonicos=vars[i],
                                    Respuestas=as.vector(paste(names(table(tab[ , vars[i]],exclude = NULL)),collapse = " ")),
                                    Cantidad=as.vector(paste(table(tab[ , vars[i]],exclude = NULL),collapse = " ")),
                                    Total=sum(table(tab[ , vars[i]],exclude = NULL))
          )
          }

        names(mylist)<-vars
        respuestas<-do.call(rbind, unique(mylist))
        respuestas$Respuestas<-as.character(respuestas$Respuestas)

        #-------------------------------------------------------------------------
        #Se concatena la respuesta y su frecuencia, se almacena en el DataFrame "respuestas" en la variable "Relacion"
        #-------------------------------------------------------------------------
        respuestas$Relacion<-""
        for(i in 1:nrow(respuestas)){
          #i<-1
          concatena<-paste(unlist(strsplit(respuestas$Respuestas[i]," ")),
                           unlist(strsplit(respuestas$Cantidad[i]," ")), sep="=")
          respuestas[i,"Relacion"] <- paste(concatena,collapse=";")
        }

        #-------------------------------------------------------------------------
        # Se separan las respuestas por renglon(split), para poder hacer el comparativo con el REQUERIMIENTO
        #-------------------------------------------------------------------------
        respuestas<-respuestas%>% separate_longer_delim(Relacion, delim = ";")
        respuestas<-respuestas%>% tidyr::separate(Relacion, c("Valores","Cantidad"), sep = '=')
        respuestas$Respuestas[respuestas$Respuestas==""] <- NA
        respuestas<-respuestas[!duplicated(respuestas[,c("Respuestas","Cantidad")]), ]
        respuestas$Porcentaje<-round((as.numeric(respuestas$Cantidad)/respuestas$Total)*100,2)
        respuestas<-respuestas[,c("V_Mnemonicos","Valores","Cantidad","Total","Porcentaje")]
        respuestas$Mnemonicos<-str_sub(respuestas$V_Mnemonicos,1,16)
        respuestas<-respuestas[respuestas$Mnemonicos!="archivo",]


        #-------------------------------------------------------------------------
        #Se extrae los valores de las variables del REQUERIMIENTO
        #-------------------------------------------------------------------------
        Req_respuestas<-VAL_COD
        Req_respuestas$V_Mnemonicos<-ifelse(Req_respuestas$cv_fac!="00",paste(Req_respuestas$Mnemonicos,Req_respuestas$cv_fac,sep="_"),Req_respuestas$Mnemonicos)
        Req_respuestas<-Req_respuestas[,c("No","Mnemonicos","V_Mnemonicos","Preguntas","Tipo","cv_fac","Respuestas","Codigo","No_Value","max","Clave")]


        #Req_respuestas<-ddply(Req_respuestas, .(V_Mnemonicos), summarize, Codigo=as.vector(paste(Codigo, collapse=" ")))

        respuestas<-left_join(respuestas,Req_respuestas[,c(6,7,11)], by=c("V_Mnemonicos"="V_Mnemonicos","Valores"="Codigo"))
        respuestas<-respuestas[,c("Mnemonicos","V_Mnemonicos","Respuestas","Valores","Cantidad","Total","Porcentaje")]

        #-------------------------------------------------------------------------
        #Se hace el comparativo ENTRE las respuestas de la tabla vs el del REQUERIMIENTO
        #-------------------------------------------------------------------------
        respuestas$Valores1<- respuestas$Valores
        Req_respuestas$Codigo1<- Req_respuestas$Codigo

        #write.xlsx(data.frame(respuestas), file=paste(RESUL,paste0("respuestas",".xlsx"),sep="/"), sheetName="respuestas1",col.names=TRUE, row.names=F,append = T)


        Validacion<-left_join(respuestas,Req_respuestas[,c(3:8,12)],by=c("V_Mnemonicos"="V_Mnemonicos","Valores1"="Codigo1"))

        Validacion<-Validacion[,c("Mnemonicos","V_Mnemonicos","cv_fac","Preguntas","Tipo","Respuestas","Valores","Cantidad","Total","Porcentaje")]
        Validacion<-Validacion[!duplicated(Validacion[,c("V_Mnemonicos","Respuestas","Valores","Cantidad")]), ]

        Validacion$Fuera_Rango<-ifelse(Validacion$Mnemonicos!="GE_02_04_04_0005"& is.na(Validacion$Respuestas),"Fuera de rango","")

        #write.xlsx(data.frame(Validacion), file=paste(RESUL,"VALIDACION.xlsx",sep="/"), sheetName="VALIDACION",col.names=TRUE, row.names=F)

        unique(Validacion[Validacion$Fuera_Rango=="Fuera de rango","V_Mnemonicos"])

        #-----------------------------------------------------------------------------------------------------------------
        #En este apartado, si se encuentran con valores fuera de rango, se reemplzan por valores aleatorios en la tabla
        #-----------------------------------------------------------------------------------------------------------------
        library("plyr")
        codigos<-ddply(Req_respuestas, .(V_Mnemonicos), summarize, Codigo=as.vector(paste(Codigo, collapse=" ")))

        Rango_Noaceptable<-codigos[codigos$V_Mnemonicos %in% unique(Validacion[Validacion$Tipo!="Opción múltiple (Abierta)"& Validacion$Fuera_Rango=="Fuera de rango","V_Mnemonicos"]),]

        #En caso de encontrar Rangos no aceptables, se procede a Reeamplazar por valores aleatorios

        set.seed(123)
        tab[,Rango_Noaceptable$V_Mnemonicos]<-apply(tab[,Rango_Noaceptable$V_Mnemonicos], MARGIN = 2, function(x) sample(c(0,1), replace = TRUE, size = length(x)))


        ##########################################################################################################################################

        # CONTINUAMOS TRABAJANDO CON LA TABLA, DESPUES DE VALIDAR LOS VALORES Y CORREGIR

        ##########################################################################################################################################

        #----------------------------------------------------------------
        #Renombrar las columnas con los Mnemonicos (hacerlo hasta que la tabla este bien estructurado)
        #----------------------------------------------------------------
        preg_catalago$cv_fac[preg_catalago$cv_fac==""] <- NA
        preg_catalago$V_Mnemonicos<-ifelse(preg_catalago$cv_fac=="00",
                                           preg_catalago$Mnemonicos,
                                           paste0(preg_catalago$Mnemonicos,"_",preg_catalago$cv_fac))
        preg_catalago<-preg_catalago[order(preg_catalago$No),]

        tabla<-tab
        colnames(tabla)<-as.vector(preg_catalago$V_Mnemonicos)
        tabla<-data.frame(lapply(tabla, function(x) {gsub("Leopoldo Cortes Chávez", "Manuel Gerardo Cossí Reyes", x)}))# Este cambio fue sugerido

        #Se detecto valores (1,2), cambiar por (1,0) en variables dicotonmica
        tabla <- tabla %>%
          mutate_at(vars(c("GE_02_04_04_0022","GE_02_04_04_0023")),~ str_replace(.,"2","0"))



        #tab<-data.frame(lapply(tab, function(x) {gsub("Parcialmente de acuerdo", "De acuerdo", x)}))
        #tab<-data.frame(lapply(tab, function(x) {gsub("Parcialmente en desacuerdo", "En desacuerdo", x)}))


        #tab<-data.frame(lapply(tab, function(x) {gsub("n/a", NA, x)}))

        ##########################################################################################################################################
        #VAMOS A REEMPLAZAR LAS RESPUESTAS POR SU VALOR
        ##########################################################################################################################################

        #variables<-unique(VAL_COD$Mnemonicos) #Automiza que agarre solo los mnemonico

        variables<-as.vector(unlist(unique(VAL_COD[VAL_COD$Tipo!="Opción múltiple (Abierta)","No"])))

        #diff<-setdiff(variables,MNEMNONICO_UNICO)

        length(variables)

        tab_cod<-data.frame(tabla)

        for(i in 1:length(variables))
          {
            #i<-1
            #print(paste0("Variable","---",variables[i]))
            print(paste0("Variable","---",colnames(tab_cod[variables[i]])))

            #columna=which(names(tab) %in% c(variables[i]))

            columna=colnames(tab_cod[variables[i]])

            VEC_AUX=as.character(unlist(tab_cod[,columna]))

            RESP<-VAL_COD%>%filter(No==variables[i])%>% select(Codigo,Clave)
            NIVELES_RESP<-stri_trim_both(as.vector(unlist(RESP[,1])))
            NIVELES_CLAV<-stri_trim_both(as.vector(unlist(RESP[,2])))

            sort.by.length.desc <- function (v) v[order( -nchar(v)) ]
            regex <- paste0("\\b(",paste(sort.by.length.desc(NIVELES_RESP), collapse="|"), ")\\b")

            VEC_AUX=str_replace_all(VEC_AUX, regex, function(word) as.character(NIVELES_CLAV)[NIVELES_RESP==word][[1]][1])
            #VEC_AUX=str_replace_all(VEC_AUX, setNames(NIVELES_CLAV, NIVELES_RESP))

            tab_cod[,columna]=VEC_AUX
        }
        #assign(Tab, tab)


        ##############################################
        #CUANDO SE GENERA "df_concat", que esla unión de
        #las multirespuesta, realizar lo siguiente
        ##############################################

        #tab_cod <- tab_cod[, -c(list_conc$No)]
        #tab_cod_fin<-cbind(tab_cod,df_concat)

        #-------------------------------------
        #------------------------------------*

        #tab_original <- tabla[, -c(list_conc$No)]
        #tab_original<-cbind(tab_original,df_concat)
        ##############################################

        #-------------------------------------------------------------------------------------------
        #Solo renombramos el dataframe como tablas final
        #-------------------------------------------------------------------------------------------
        tab_cod_fin<-tab_cod
        tab_original <- tabla

        #write.xlsx(data.frame(tab), file=paste(RESUL,paste0(Tab,".xlsx"),sep="/"), sheetName=Tab,col.names=TRUE, row.names=F)

        #Codificadas[[Tab]] <-tab
      #}

    #preg_catalago <- preg_catalago[order(preg_catalago$No),]
    #preg_catalago$MNEMONICO<-ifelse(is.na(preg_catalago$MNEMONICO),preg_catalago$Mnemonicos,preg_catalago$MNEMONICO)
    #preg_catalago$TIPO_DE_PREGUNTA<-ifelse(is.na(preg_catalago$TIPO_DE_PREGUNTA),"Control",preg_catalago$TIPO_DE_PREGUNTA)
    #preg_catalago$PREGUNTAS<-ifelse(is.na(preg_catalago$PREGUNTAS),preg_catalago$Preguntas,preg_catalago$PREGUNTAS)
    #preg_catalago <- preg_catalago[order(preg_catalago$No),]


    #catalago_new<-preg_catalago[!duplicated(preg_catalago[,c("MNEMONICO","cv_fac")]), ]
    #catalago_new$V_Mnemonicos<-ifelse(is.na(catalago_new$cv_fac),catalago_new$MNEMONICO,paste0(catalago_new$MNEMONICO,"_",catalago_new$cv_fac))

    #-------------------------------------------------------------------------------------------
    #Se crea un nuevo catalado, que tenga los Mnemonicos y preguntas que llevará la tabla final
    #-------------------------------------------------------------------------------------------
    catalago_new<-preg_catalago %>%
      select("No","Mnemonicos","cv_fac","V_Mnemonicos","MNEMONICO","TIPO_DE_PREGUNTA","PREGUNTAS","OPCIONES_DE_RESPUESTA","TIPO_DE_RESPUESTA")

    catalago_new<-catalago_new[!is.na(catalago_new$MNEMONICO),]

    #catalago_new$Preguntas<-ifelse(is.na(catalago_new$Preguntas),catalago_new$Mnemonicos,catalago_new$Preguntas)
    catalago_new$cv_fac<-ifelse(str_detect(catalago_new$MNEMONICO,"(?=.*[0-9]).*")==T,catalago_new$cv_fac,NA)
    catalago_new$labels<- ifelse(str_detect(catalago_new$MNEMONICO,"(?=.*[0-9]).*")==T & !is.na(catalago_new$cv_fac),
                              paste0(catalago_new$PREGUNTAS,"(",paste0(catalago_new$MNEMONICO,"_",catalago_new$cv_fac),")"),
                              catalago_new$PREGUNTAS)

    #catalago_new$labels<-ifelse(is.na(catalago_new$TIPO_DE_RESPUESTA),catalago_new$MNEMONICO,catalago_new$labels)

    #catalago_new$Mnem_fin<-ifelse(is.na(catalago_new$cv_fac),catalago_new$MNEMONICO,paste0(catalago_new$MNEMONICO,"_",catalago_new$cv_fac))
    catalago_new$OPCIONES_DE_RESPUESTA<-str_replace_all(catalago_new$OPCIONES_DE_RESPUESTA, "[\r\n]" , "")
    catalago_new <- catalago_new[order(catalago_new$No),]

    #Mnem_fin<-ifelse(is.na(catalago_new$cv_fac),catalago_new$Mnemonicos,paste0(catalago_new$Mnemonicos,"_",catalago_new$cv_fac))

    tab_cod_fin <- tab_cod_fin %>% dplyr::select(as.vector(catalago_new$V_Mnemonicos), everything())# Ordenar columnas, colocandolos al inicio
    tab_original<-tab_original %>% dplyr::select(as.vector(catalago_new$V_Mnemonicos), everything())# Ordenar columnas, colocandolos al inicio

    tab_cod_fin<-data.frame(tab_cod_fin)
    tab_original<-data.frame(tab_original)

    #word<-c("Otra","Otras","Otro","Otros")
    #tab_original<-data.frame(lapply(tab_original, function(x) {gsub(paste(word, collapse = "|"), "Otras", x)}))

    #write.xlsx(data.frame(tab_cod_fin), file=paste(RESUL,paste0("SIMULADA","_CODIFICADA",".xlsx"),sep="/"), sheetName="CODIFICADA",col.names=TRUE, row.names=F)
    #write.xlsx(data.frame(tab_original), file=paste(RESUL,paste0("SIMULADA","_HOMOLOGADA_",".xlsx"),sep="/"), sheetName="HOMOLOGADA",col.names=TRUE, row.names=F)





#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
#3. COMIENZA LA EXPLOTACIÓN DE LA INFORMACIÓN
#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&


    ##########################################################################################################################################
    # 1. SE CALCULA LAS FRECUENCIAS PARA CADA VARIABLE                #
    ##########################################################################################################################################

    #word<-c("Otra","Otras","Otro","Otros")
    #VAL_COD$Respuestas <- gsub(paste(word, collapse = "|"), "Otras", VAL_COD$Respuestas)
    #catalago_new$OPCIONES_DE_RESPUESTA<-gsub(paste(word, collapse = "|"), "Otras", catalago_new$OPCIONES_DE_RESPUESTA)
    #tab_original<-data.frame(lapply(tab_original, function(x) {gsub(paste(word, collapse = "|"), "Otras", x)}))

    library(freqtables)

    vars<- unique(catalago_new[catalago_new$TIPO_DE_RESPUESTA %!in% c(NA,"Abierta","Opción múltiple (Abierta)"),"V_Mnemonicos"])
    #------------------------------------------------
    #Frecuencias para respuestas unicas
    #------------------------------------------------

    dt_res = data.frame()
    for (i in 1:length(vars)){
      #i<-1
      df1 = data.frame(Var=vars[i],t(table(tab_original[,vars[i]])))
      df2 = data.frame(Var=vars[i],
                       t(table(factor(tab_original[,vars[i]], levels = as.factor(unique(tab_original[,vars[i]]))))/nrow(tab_original) * 100)
      )
      colnames(df2)<-c("Var","Var1","Var2","Freq2")
      df<-left_join(df1, df2[,c(1,3,4)], by= "Var2")

      df<-df[,c(1,3,4,6)]
      dt_res = rbind(dt_res, df)
    }

    colnames(dt_res)<-c("Mnemonicos","Codigo","Cantidad", "Porcentaje")

    #------------------------------------------------
    #Frecuencias para preguntas con multirespuestas
    #------------------------------------------------
    vars_mul<- unique(catalago_new[!is.na(catalago_new$cv_fac) & catalago_new$MNEMONICO!="GE_02_04_04_0005" &
                            catalago_new$TIPO_DE_RESPUESTA %in% c("Opción múltiple (Abierta)"),"V_Mnemonicos"])

    dt_res2 = data.frame()
    for (j in 1:length(vars_mul)){
      #j<-1
      var<-unlist(strsplit(tab_original[,vars_mul[j]],";"))

      df1 = data.frame(Var=vars_mul[j],t(table(var)))

      df2 = data.frame(Var=vars_mul[j],
                      t(table(factor(var, levels = as.factor(unique(var))))/nrow(tab_original)*100) #length(var):No es sobre el número de respuesta, es sobre el número de registro de la tabla
      )
      colnames(df1)<-c("Var","Var1","Var2","Freq")
      colnames(df2)<-c("Var","Var1","Var2","Freq2")
      df<-left_join(df1, df2[,c(1,3,4)], by= "Var2")

      df<-df[,c(1,3,4,6)]
      dt_res2 = rbind(dt_res2, df)
    }

    colnames(dt_res2)<-c("Mnemonicos","Codigo","Cantidad", "Porcentaje")

    word<-c("Otra","Otras","Otro","Otros") #Realizo la homogenzación de algunas respuestas
    dt_res2$Codigo<-gsub(paste(word, collapse = "|"), "Otras", dt_res2$Codigo)


    df_var<-VAL_COD[VAL_COD$Mnemonicos!="GE_02_04_04_0005",c(2,3,4,5,6,7)]
    df_var$V_Mnemonicos<-ifelse(df_var$cv_fac!="00",paste(df_var$Mnemonicos,df_var$cv_fac,sep="_"),df_var$Mnemonicos)
    df_var$Codigo<-ifelse(df_var$Tipo=="Opción múltiple (Abierta)",df_var$Respuestas,df_var$Codigo)
    df_var$Codigo<-str_replace_all(tolower(stri_trans_general(df_var$Codigo, id="Latin-ASCII"))," ","")

    dt_res2$Codigo<-str_replace_all(tolower(stri_trans_general(dt_res2$Codigo, id="Latin-ASCII"))," ","")
    df_var_mul<-df_var[df_var$Tipo=="Opción múltiple (Abierta)",c("Mnemonicos","Respuestas","Codigo")]

    dt_res2<-left_join(dt_res2,df_var_mul, by=c("Mnemonicos"="Mnemonicos","Codigo"="Codigo"))
    dt_res2<-dt_res2[,c(1,5,3,4)]
    colnames(dt_res2)<-colnames(dt_res)

    #dt_res2[is.na(dt_res2)] <- "Otras"
    #colnames(dt_res2)[2] <- "Codigo"

    #dt_res2<-dt_res2 %>%
      #group_by(Mnemonicos,Codigo) %>%
      #summarise(Cantidad = sum(Cantidad),
                #Porcentaje = sum(Porcentaje)
                #)
    #------------------------------------------------
    #Unión de las frecuencias: Respuestas únicas y multirespuestas
    #------------------------------------------------
    df_freq<-rbind(dt_res,dt_res2)
    df_freq$Codigo<-str_replace_all(tolower(stri_trans_general(df_freq$Codigo, id="Latin-ASCII"))," ","")

    Tabulado_freq <- left_join(df_var,df_freq, by=c("V_Mnemonicos"="Mnemonicos","Codigo"="Codigo"))
    Tabulado_freq <- Tabulado_freq[order(Tabulado_freq$Mnemonicos),]


    Tabulado_freq<-Tabulado_freq[,c(1,7,2,3,5,6,8,9)]
    Tabulado_freq$Porcentaje<-round(Tabulado_freq$Porcentaje,2)
    Tabulado_freq$Total<-nrow(tab_original)

    Tabulado_freq<-Tabulado_freq %>% distinct(V_Mnemonicos,Respuestas, .keep_all = TRUE)

    Tabulado_freq$DUP<-ifelse(duplicated(paste(Tabulado_freq$V_Mnemonicos,Tabulado_freq$Respuestas,sep="/"))==T,1,0)

     ##################################################################
    # Plot de Frecuencias para cada variable                  #
    #################################################################

    Tabulado_freq <-Tabulado_freq%>%
      group_by(V_Mnemonicos) %>%
      dplyr::mutate(N_preg =n())


    #------------------------------------------------
    #Se crea la variable "plot_ly", como parametro para los gráficos
      #----pie: Gráfico de paste
      #----donut: Grafico de donas
      #----bar_h: Gráfico de barra horizontal
      #----funnel: Gráfico de piramide
    #Checar sus definiciones en "ESTRATEGIA PARA LA GENERACIÓN DE INSUMOS PARA LA EVALUACIÓN - GG - 01112024.doc"
    #------------------------------------------------
    Tabulado_freq <- Tabulado_freq %>% mutate(plot_ly = case_when(
      N_preg <= 2 ~ "pie",
      N_preg <= 3 ~ "donut",
      N_preg <= 5 ~ "bar_h",
      N_preg > 5 ~ "funnel")
    )


    #------------------------------------------------
    # Se crean etiquetas para los números, títulos para los gráficos
    #------------------------------------------------

    Tabulado_freq<-as.data.frame(Tabulado_freq)
    Tabulado_freq$Porcentaje<-ifelse(is.na(Tabulado_freq$Porcentaje),0,Tabulado_freq$Porcentaje)
    Tabulado_freq$Preguntas<-gsub("[\r\n]", "",Tabulado_freq$Preguntas)
    Tabulado_freq$Respuestas<-gsub("[\r\n]", "",Tabulado_freq$Respuestas)

    Tabulado_freq <- Tabulado_freq %>% mutate(Text = case_when(
      Porcentaje!= 0 & plot_ly=="pie" ~ paste(Respuestas,"<br>",Porcentaje,"%",sep=""),
      Porcentaje!= 0 & plot_ly=="donut" ~ paste(Respuestas,"<br>",Porcentaje,"%",sep=""),
      Porcentaje!= 0 & plot_ly=="bar_h" ~ paste(Porcentaje,"%",sep=""),
      TRUE ~ ""
    ))

    Tabulado_freq <- inner_join(Tabulado_freq, REQUERIMIENTO[,c(1,15)], by = c("Mnemonicos"="MNEMONICO"))
    Tabulado_freq$INDICADOR<-str_replace_all(Tabulado_freq$INDICADOR, "[\r\n]", "")
    Tabulado_freq$cv_fac<-str_sub(Tabulado_freq$V_Mnemonicos,18,19)

    Tabulado_freq$cv_fac[Tabulado_freq$cv_fac==""] <- NA
    Tabulado_freq$cv_fac<-ifelse(is.na(Tabulado_freq$cv_fac),"00",Tabulado_freq$cv_fac)
    Tabulado_freq <- Tabulado_freq %>% mutate(Facilitador = case_when(
      cv_fac== "00" ~ "General",
      cv_fac== "01" ~ "Manuel Gerardo Cossí Reyes",
      cv_fac== "02"	~ "Jorge Alejandro Reyes Eguren",
      cv_fac== "03"	~ "Juan Ramón Mena",
      cv_fac== "04"	~ "Maritza González Huitrón",
      cv_fac== "05"	~ "Laura Noemí Guzmán Moreno",
      cv_fac== "06"	~ "Cecilia Martinez Serrano",
      cv_fac== "07"	~ "María Fernanda Salina Álvarez",
      )
    )

    Tabulado_freq$cv_ind<-paste(Tabulado_freq$INDICADOR,Tabulado_freq$cv_fac,sep="_")

    setDT(Tabulado_freq)[, seq_cod := seq_len(.N), .(V_Mnemonicos, rleid(Preguntas))]

    #------------------------------------------------
    #Exportar en formato EXCEL las frecuencias
    #------------------------------------------------
    write.xlsx(data.frame(Tabulado_freq), file=paste(RESUL,"FRECUENCIAS_131124.xlsx",sep="/"), sheetName="FRECUENCIAS",col.names=TRUE, row.names=F,append = T)

    #Tabulado_freq$Porcentaje<-ifelse(Tabulado_freq$Porcentaje==0,NA,Tabulado_freq$Porcentaje)

    library(plotly)
    library(orca)

    #---------------------------------------------------------------------
    #SE GENERAN GRÁFICOS Y SE GUARDAN EN LA CARPETA: GRAFICAS>FRECUENCIAS_FECHA
    #---------------------------------------------------------------------
    n_var<-as.vector(unlist(unique(Tabulado_freq$V_Mnemonicos)))
    colum<-c("V_Mnemonicos","Preguntas","Tipo","Respuestas","Codigo","Cantidad",
                  "Porcentaje","Total","N_preg","plot_ly","Text","INDICADOR","cv_fac","Facilitador","cv_ind")

    Tabulado_freq<-data.frame(Tabulado_freq)

    #length(n_var)
    for (k in 1:length(n_var)){

      #k<-1
      df<-Tabulado_freq[Tabulado_freq$V_Mnemonicos==n_var[k],colum]
      df$Respuestas <- factor(df$Respuestas, levels = as.vector(unique(unlist(df$Respuestas))),ordered = TRUE)
      tipo_grafico<-as.vector(unlist(unique(df[,c("plot_ly")])))
      Tit<-ajuste(as.vector(unlist(unique(df[,"Preguntas"]))))
      Subt<-as.vector(unlist(unique(df[,"Facilitador"])))

      fig<-as.vector(unlist(unique(df[,1])))
      #colores <- brewer.pal(8, "Dark2")

      # Simulate a conda environment to use Kaleido
      #reticulate::install_miniconda()
      #reticulate::conda_install('r-reticulate', 'python-kaleido')
      #reticulate::conda_install('r-reticulate', 'plotly', channel = 'plotly')
      #reticulate::use_miniconda('r-reticulate')


      p<-graficos(df,tipo_grafico,Tit,Subt)

      save_image(p, paste("01_SIMULACION/RESULTADO/GRAFICAS/FRECUENCIAS_131124/VARIABLES/",fig,".png",sep=""),scale=6, width=700, height=500)

      #dev.off()

    }

    #trim_space("01_SIMULACION/RESULTADO/GRAFICAS/FRECUENCIAS/",".png") #Es una función para elminar border en blanco

    #====================================
    #Frecuencias por indicador
    #====================================
    #length(Indicador)

    colum<-c("V_Mnemonicos","Preguntas","Tipo","Respuestas","Codigo","Cantidad",
             "Porcentaje","Total","N_preg","plot_ly","Text","INDICADOR","cv_fac","Facilitador","cv_ind","seq_cod")

    Indicador<-as.vector(unlist(unique(Tabulado_freq[!is.na(Tabulado_freq$INDICADOR) & Tabulado_freq$Tipo!="Opción múltiple (Abierta)","cv_ind"])))

    for (i in 1:length(Indicador)){

      #i<-33
      df<-Tabulado_freq[Tabulado_freq$cv_ind==Indicador[i],colum]
      df<-df[!is.na(df$INDICADOR),]
      df <- df[order(df$V_Mnemonicos,df$seq_cod,df$Porcentaje,decreasing=FALSE),]

      Tit<-as.vector(unlist(unique(df$INDICADOR)))
      Subt<-as.vector(unlist(unique(df$Facilitador)))

      p<-graficos_agrup(df,Tit,Subt)
      save_image(p, paste("01_SIMULACION/RESULTADO/GRAFICAS/FRECUENCIAS_131124/INDICADORES/",Indicador[i],".png",sep=""),scale=6, width=700, height=500)

    }

    #trim_space("01_SIMULACION/RESULTADO/GRAFICAS/FRECUENCIAS/INDICADORES/",".png") #Es una función para elminar border en blanco




    ##########################################################################################################################################
    # 2. SE CALCULAN LOS INDICADORES
    ##########################################################################################################################################

    ##################################################################
    # Integración de las preguntas para crear indicadores            #
    ##################################################################

    REQUERIMIENTO$INDICADOR<-str_replace_all(REQUERIMIENTO$INDICADOR, "[\r\n]" , "")

    lista_indica <- merge(catalago_new, REQUERIMIENTO[,c(1,15)], by = "MNEMONICO", all.x = TRUE)
    lista_indica<-lista_indica[lista_indica$TIPO_DE_RESPUESTA %!in%c("Abierta","Opción múltiple (Abierta)",NA),]

    lista_indica$indicador<-ifelse(is.na(lista_indica$cv_fac),lista_indica$INDICADOR,paste(lista_indica$INDICADOR,lista_indica$cv_fac,sep="_"))
    lista_indica <- lista_indica[order(lista_indica$No),]


    Ind_label<-unique(lista_indica$indicador)
    Ind_no<-length(Ind_label)

    list_ind<-list()

    for(i in 1:length(Ind_label)){
      Mnemicos<-as.vector(unlist(lista_indica[lista_indica$indicador==Ind_label[i],"V_Mnemonicos"]))
        index=which(colnames(tab_cod_fin) %in% Mnemicos)
        if (any(Mnemicos %in% colnames(tab_cod_fin))==T && length(index)>0){
          #df<-Cuest[,index]
          df<-tab_cod_fin[colnames(tab_cod_fin) %in% Mnemicos]
          df_ind<-data.frame(df)
        }
      list_ind[[i]] <- df_ind #Se almacenan los Mnemonicos
    }

    names(list_ind)<-Ind_label


  ##################################################################
  # Crear los indicadores                                          #
  ##################################################################

    #---------------------------------------------------------------------
    #Función para detectar al valor alfanumerico en las variables
    #---------------------------------------------------------------------
    detect_anycharacter<-function(df){
      vect<-unique(as.vector(unlist((apply(df, 1,function(x) str_extract_all(x,'(?![-;/&,])[^[Aa-zZ]]'))))))
      if (any(grepl("[A-Za-z]", vect))==T) {
        0
        #print("existe variables con letras")
      } else {1}
    }


    #---------------------------------------------------------------------
    # Se almacenan en una lista todos calculos, es decir, los promedios
    #---------------------------------------------------------------------
    list_IND<-list()

    for(i in 1:length(Ind_label)){
      #i<-2
      df<-data.frame(list_ind[[i]])
      #df<-df%>%select(-Tabla)
      if(detect_anycharacter(df)==1){
        df_num<-df%>% mutate_if(is.character,as.numeric)
        #INDICADOR<-data.frame(PROMEDIO=colMeans(df_num))

        INDICADOR <- data.frame(SUM=apply(df_num, 2, sum, na.rm=TRUE),
                                MAX=apply(df_num, 2, max, na.rm=TRUE),
                                MIN=apply(df_num, 2, min, na.rm=TRUE),
                                MED=apply(df_num, 2, median, na.rm=TRUE),
                                PROM=apply(df_num, 2, mean, na.rm=TRUE)
                                )
        INDICADOR<-data.frame(Indicador=Ind_label[i],
                              Mnemonicos=rownames(INDICADOR),
                              INDICADOR)

        pregunt<-catalago_new[catalago_new$V_Mnemonicos %in% as.vector(INDICADOR$Mnemonicos),c("V_Mnemonicos","PREGUNTAS","TIPO_DE_RESPUESTA","cv_fac")]

        INDICADOR <- merge(INDICADOR, pregunt, by.x = "Mnemonicos",by.y="V_Mnemonicos")
        #INDICADOR <- INDICADOR[, c(1,4,5,2,6,3)]
        #INDICADOR<-data.frame(Indicador=Ind_label[i],INDICADOR)
        list_IND[[i]] <- INDICADOR

      }else{
        print(paste0(i,"--",names(list_ind[i])))
      }
    }

    #---------------------------------------------------------------------
    # Se convierte en DATAFRAME la lista de promedios calculado anteriormente
    # y se le da cierto formato
    #---------------------------------------------------------------------

    #a) Promedio por preguntas
    PROM_PREG<-do.call(rbind, unique(list_IND))
    PROM_PREG$Indicador<-gsub(paste(paste0("_",PROM_PREG$cv_fac),collapse = "|"),"",PROM_PREG$Indicador)

    PROM_PREG <- PROM_PREG %>% mutate(Facilitador = case_when(
      cv_fac== "00" ~ "General",
      cv_fac== "01" ~ "Manuel Gerardo Cossí Reyes",
      cv_fac== "02"	~ "Jorge Alejandro Reyes Eguren",
      cv_fac== "03"	~ "Juan Ramón Mena",
      cv_fac== "04"	~ "Maritza González Huitrón",
      cv_fac== "05"	~ "Laura Noemí Guzmán Moreno",
      cv_fac== "06"	~ "Cecilia Martinez Serrano",
      cv_fac== "07"	~ "María Fernanda Salina Álvarez",
    )
    )

    #b) Promedio por Facilitador
    PROM_IND_FAC<-aggregate(PROM_PREG$PROM, by=list(PROM_PREG$Indicador,PROM_PREG$cv_fac), FUN=mean)
    colnames(PROM_IND_FAC)<-c("INDICADOR","cv_fac","PROM")

    #c) Promedio por indicadores de forma general
    PROM_IND<-aggregate(PROM_PREG$PROM, by=list(PROM_PREG$Indicador), FUN=mean)
    colnames(PROM_IND)<-c("INDICADOR","PROM_G")


    #---------------------------------------------------------------------
    # Conjuntar los promedios por Facilitador y Temas (Indicadores)
    #---------------------------------------------------------------------
    library(tm)

    INDICADORES <- merge(PROM_IND_FAC, PROM_IND, by.x = "INDICADOR",by.y="INDICADOR")
    INDICADORES <- INDICADORES[order(INDICADORES$cv_fac),]
    INDICADORES$order <- ave(INDICADORES$INDICADOR,INDICADORES$cv_fac,FUN = seq_along)

    INDICADORES <- INDICADORES %>% mutate(Facilitador = case_when(
      cv_fac== "00" ~ "General",
      cv_fac== "01" ~ "Manuel Gerardo Cossí Reyes",
      cv_fac== "02"	~ "Jorge Alejandro Reyes Eguren",
      cv_fac== "03"	~ "Juan Ramón Mena",
      cv_fac== "04"	~ "Maritza González Huitrón",
      cv_fac== "05"	~ "Laura Noemí Guzmán Moreno",
      cv_fac== "06"	~ "Cecilia Martinez Serrano",
      cv_fac== "07"	~ "María Fernanda Salina Álvarez",
    )
    )

    INDICADORES<-INDICADORES[,c("INDICADOR","Facilitador","cv_fac","PROM","PROM_G","order")]

    #---------------------------------------------------------------------
    #Exportar el dataframe con los INDICADORES
    #---------------------------------------------------------------------
    write.xlsx(data.frame(INDICADORES), file=paste(RESUL,"INDICADORES2.xlsx",sep="/"), sheetName="INDICADORES",col.names=TRUE, row.names=F,append = T)

    ##################################################################
    # Gráficos de promedios de preguntas según indicadores, se agrega el total#
    ##################################################################

    #------------------------------------------------
    #Se crea la variable "plot_ly", como parametro para los gráficos
    #----gauge: Gráfico de tipo medidor
    #----bar_h: Gráfico de barra horizontal
    #Checar sus definiciones en "ESTRATEGIA PARA LA GENERACIÓN DE INSUMOS PARA LA EVALUACIÓN - GG - 01112024.doc"
    #------------------------------------------------
    PROMEDIOS<-PROM_PREG
    PROMEDIOS$cv_ind<-ifelse(PROMEDIOS$Facilitador=="General",PROMEDIOS$Indicador,paste(PROMEDIOS$Indicador,PROMEDIOS$cv_fac,sep="_"))
    PROMEDIOS <- PROMEDIOS[order(PROMEDIOS$cv_fac),]
    PROMEDIOS$Porcentaje<-round(PROMEDIOS$PROM*100,2)
    PROMEDIOS$N_preg<-ave(PROMEDIOS$cv_ind,PROMEDIOS$cv_ind,FUN=length)
    #PROMEDIOS$Text<-paste(PROMEDIOS$Porcentaje,"%",sep="")
    PROMEDIOS$Text<-PROMEDIOS$Porcentaje
    names(PROMEDIOS)[8:9]<-c("Preguntas","Tipo")
    PROMEDIOS <- PROMEDIOS %>% mutate(plot_ly = case_when(
      N_preg <= 1 ~ "gauge",
      N_preg > 1 ~ "bar_h"
    ))

    #------------------------------------------------
    # Se crean etiquetas para los gráficos
    #------------------------------------------------
    total<-INDICADORES[,c(1,3,4)]
    colnames(total)<-c("Indicador","cv_fac","PROM")
    total$cv_ind<-ifelse(total$cv_fac=="00",total$Indicador,paste(total$Indicador,total$cv_fac,sep="_"))
    total$Desgloce<-"01"
    total <-right_join(PROMEDIOS[,-7],total[,c("PROM","cv_ind","Desgloce")], by=c("cv_ind"="cv_ind"))
    total[,c(1,3,4,5,6,7,8,12,14)]<-NA
    total$Porcentaje<-round(total$PROM*100,2)
    total$Text<-total$Porcentaje
    total<-total[total$N_preg>1,]
    total$Preguntas<-"Total"

    PROMEDIOS$Desgloce<-"00"

    PROMEDIOS<-bind_rows(PROMEDIOS,total)
    PROMEDIOS <- PROMEDIOS[order(PROMEDIOS$Indicador,PROMEDIOS$cv_ind,PROMEDIOS$Desgloce),]
    PROMEDIOS<-PROMEDIOS[!duplicated(PROMEDIOS[,c("Indicador","cv_ind","PROM","Desgloce")]), ]
    PROMEDIOS <- PROMEDIOS[order(PROMEDIOS$Indicador,PROMEDIOS$cv_ind,PROMEDIOS$Desgloce),]

  #write.xlsx(data.frame(PROMEDIOS), file=paste(RESUL,"PROMEDIOS.xlsx",sep="/"), sheetName="PROMEDIOS",col.names=TRUE, row.names=F,append = T)

    #------------------------------------------------
    # Se crean 40 gráficos, representan los promedios de cada pregunta según tema (indicadores)
    #------------------------------------------------
    Indicador<-as.vector(unlist(unique(PROMEDIOS[!is.na(PROMEDIOS$Indicador),"cv_ind"])))


    for (i in 1:length(Indicador)){

      #i<-1
      df<-PROMEDIOS[PROMEDIOS$cv_ind==Indicador[i],c(1,2,7,8,9,11,12,13,14,15,16)]
      df<-df[!is.na(df$Indicador),]
      df <- df[order(df$Mnemonicos,df$Porcentaje,decreasing=FALSE),]
      tipo_grafico<-as.vector(unlist(unique(df$plot_ly)))

      Tit<-as.vector(unlist(unique(df$Indicador)))
      Subt<-as.vector(unlist(unique(df$Facilitador)))

      p<-plot_indica(df,tipo_grafico,Tit,Subt)

      save_image(p, paste("01_SIMULACION/RESULTADO/GRAFICAS/INDICADORES_131124/INDICADORES/",Indicador[i],".png",sep=""),scale=6, width=700, height=500)

    }

    #trim_space("01_SIMULACION/RESULTADO/GRAFICAS/INDICADORES/INDICADORES/",".png")

  ##################################################################
  # Diversos gráficos por tema(indicadores)                        #
  ##################################################################

  library(ggplot2)
  library(plotly)

  #&&&&&&&&&&&&&&&&&&&&&&
  # INDICADORES ÚNICOS
  #&&&&&&&&&&&&&&&&&&&&&&
  df_general<-unique(INDICADORES[,c("INDICADOR","PROM_G")])
  #====================================
  #CIRCULAR
  #====================================
  ggplot(INDICADORES, aes(y = PROM, x = reorder(str_wrap(INDICADOR,10), order),group = cv_fac, colour = cv_fac)) +
  #ggplot(df_general, aes(y = PROM_G, x = reorder(str_wrap(INDICADOR,10), order),colour = INDICADOR)) +
    coord_polar() +
    geom_point() +
    geom_path() +
    labs(title="Todos los Indicdores (facilitadores y general)",
         caption="Reaserch",
         y = NULL, x = NULL, color = NULL)+
    theme(#legend.position = "none",
          text=element_blank(),
          plot.title=element_text(size=10, hjust=0.2, face='bold'),
          plot.subtitle=element_text(size=9, hjust=0.2),
          axis.text.x = element_text(size=7, hjust=0.1, face='italic'),
          axis.title.x = element_blank(),
          panel.grid.minor = element_blank(),
          axis.ticks.y = element_blank())

  ggsave("01_SIMULACION/RESULTADO/GRAFICAS/INDICADORES_131124/VARIABLES/00_Circular_General.png")

  #====================================
  # RADAR
  #====================================

  fig <- plot_ly(type = 'scatterpolar',fill = 'toself')
  fig <- fig %>%
    add_trace(
      r = (df_general$PROM_G)*100,
      theta =str_wrap(df_general$INDICADOR,25) ,
      #name = str_wrap(df_general$INDICADOR,27),
      text=paste(round(df_general$PROM_G,4)*100,"%",sep=""),
      textfont = list(color = "black", size =10),
      width = 1200, height = 600, showlegend = FALSE
      #color=df_general$INDICADOR
    )%>%
    layout(title = list(text ="Valor de los indicadores",y=0.99,x=0.5,font = font_title),
           autosize = T,
           margin=list( l = 100, r = 100, b = 0, t = 60,  pad = 4),
           polar=list(
                      radialaxis =list(
                                  angle = 90,ticksuffix = '%',
                                  tickangle = 90,tickvals=seq(0,100,25),
                                  ticktext = "%",
                                  range = c(0, 100)
                                      )
                      )
    )
  fig

  save_image(fig, "01_SIMULACION/RESULTADO/GRAFICAS/INDICADORES_131124/VARIABLES/00_Radar_General.png")


  #====================================
  #CIRCULAR CON BARRAS
  #====================================
  library(geomtextpath)

  p<-ggplot(df_general, aes(x=str_wrap(df_general$INDICADOR,20), y=PROM_G,
                         fill=factor(str_wrap(df_general$INDICADOR,20)))) +
    geom_bar(width = 1,stat="identity",colour = "black")+
    geom_text(aes(label=round(PROM_G,4)*100,family = "sans-serif"),position = position_stack(vjust = 0.9),size=2)

  p_text <- p + coord_polar()+
    #p_text <- p +coord_curvedpolar+
     labs(title="Valor de los indicadores",
         y = NULL, x = NULL, color = NULL)+
    theme(legend.position = "none",
          text=element_blank(),
          plot.title=element_text(size=10, hjust=0.5, face='bold'),
          plot.subtitle=element_text(size=7, hjust=0.2),
          axis.text.x = element_text(family = "sans-serif",size =  5,color = "black"),
          axis.title.x = element_blank(),
          panel.grid.minor = element_blank(),
          axis.ticks.y = element_blank())

  p_text

  ggsave("01_SIMULACION/RESULTADO/GRAFICAS/INDICADORES_131124/VARIABLES/00_Circular_Barra_General.png")


  #====================================
  #LOLLIPOP
  #====================================

  ggplot(df_general, aes(x=str_wrap(INDICADOR,30), y=round(PROM_G,4)*100, label=format(round(PROM_G,4)*100,nsmall=2))) +
    #geom_bar(stat='identity', aes(fill=CONFIABILIDAD), width=.5)+
    geom_point(stat='identity', aes(col=INDICADOR), size=10,show.legend = FALSE) +
    geom_text(color="black", size=2) +
    #scale_color_manual(name="Cofiabilidad",labels = c("Alta", "Media","Baja"),values = c("Alta"="#01ABAA","Media"="#00ba38","Baja"="red")) +
    #geom_text(aes(label=etiquetar_numero(round(PROM,1),2,etiquetar="")),color="black", size=2,vjust=0.5, hjust=-0.5) +

    labs(title="Valor de los indicadores") +
    scale_y_continuous(limits = c(10,100),breaks = seq(from =10, to = 100, by = 10))+
    coord_flip()+

    theme(
      plot.margin = unit(c(1,1,1,1), "cm"),
      axis.text.x = element_text(size =7,vjust=0.5, hjust=1,angle = 0),
      axis.text.y = element_text(size =7,vjust=0.5,hjust=1),
      legend.title = element_text(size=8),
      legend.text = element_blank(),
      legend.key.height= unit(0.5, 'cm'),
      legend.key.width= unit(0.5, 'cm'),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      plot.title = element_text(size =10),
      plot.subtitle = element_text(size =8)
    )#+
    #guides(color = guide_legend(title="Facilitador",override.aes = list(size = 1)))

  ggsave("01_SIMULACION/RESULTADO/GRAFICAS/INDICADORES_131124/VARIABLES/00_lollipop_General.png")


  bullet_colors <- c("#E9FFE3", "#A3D694", "#61AB40", "#318100")
  names(bullet_colors) <- c("Poor", "Ok", "Good", "Excellent")

  df_general <- df_general %>% mutate(rank = case_when(
    0.0 <= PROM_G & PROM_G <= 0.6 ~ "Poor",
    0.6 < PROM_G  & PROM_G <= 0.7 ~ "Ok",
    0.7 < PROM_G & PROM_G <= 0.8 ~ "Good",
    0.8 < PROM_G & PROM_G <= 1.0 ~ "Excellent"
  ))

  df_general$Porcentaje<-round(df_general$PROM_G*100,2)
  df_general <- df_general[order(df_general$INDICADOR),]
  df_general<-df_general[!duplicated(df_general[,c("INDICADOR")]), ]


  ggplot(df_general, aes(str_wrap(INDICADOR,30), y = Porcentaje)) +
    geom_bar(data = df_general,aes(x = str_wrap(INDICADOR,30), y = Porcentaje, fill = rank), stat = "identity",
             position = "stack") +
    geom_bar(data = df_general,aes(x =str_wrap(INDICADOR,30), y = Porcentaje), fill = "black", width = 0.15,
             stat = "identity") +
    scale_fill_manual(values = bullet_colors) +
    scale_y_continuous(lim=c(0,105),breaks=seq(0,100,by=10))+
    coord_flip(expand = FALSE)+
    geom_text(aes(label=Porcentaje),hjust = -0.5, size = 2,fontface = "bold", family = "italic",
              position = position_dodge(width = 1),inherit.aes = TRUE)+
    labs(title="Valor promedio por cada indicador",x="",y="")+
    theme(
      #axis.text.y = element_blank(),
      legend.position = "none",
      axis.title = element_text(size=8, hjust=0.1, face='italic'),
      axis.text.y = element_text(size=5, hjust=0.1, face='italic'),
      axis.text.x = element_text(size=5, hjust=0.1, face='italic'),
      axis.title.x = element_blank(),
      panel.grid.minor = element_blank(),
      axis.ticks.y = element_blank(),
      axis.ticks.x = element_blank()
    )+
    guides(colour = guide_legend(nrow = 3))

  ggsave("01_SIMULACION/RESULTADO/GRAFICAS/INDICADORES_131124/VARIABLES/00_barr_General.png")


  #&&&&&&&&&&&&&&&&&&&&&&
  #Solo para facilitadores
  #&&&&&&&&&&&&&&&&&&&&&&

  df_Fac<-INDICADORES[INDICADORES$cv_fac!="00",c("INDICADOR","PROM","cv_fac","Facilitador","order")]

  #====================================
  #CIRCULAR
  #====================================

  brk<-seq(from =0, to = 100, by = 10)

  ggplot(df_Fac, aes(y = PROM, x = reorder(str_wrap(INDICADOR,15), order),
                                                     group = Facilitador, colour = Facilitador)) +
    coord_polar() +
    geom_point() +
    geom_path() +
    labs(title="Indicadores para facilitadores",y=NULL, x=NULL, color=NULL)+
    #annotate('text',x = 0, y = brk,label = as.character(brk))+
    theme(#legend.position = "none",
        legend.position="bottom",
        legend.text=element_text(size=4),
          text=element_blank(),
          panel.border=element_blank(),
          plot.title=element_text(size=10, hjust=0.2, face='bold'),
          #plot.subtitle=element_text(size=9, hjust=0.2),
          axis.text.y = element_blank(),
          axis.text.x = element_text(size=6, hjust=0.1, face='italic'),
          axis.title.x = element_blank(),
          panel.grid.minor = element_blank(),
          axis.ticks.y = element_blank(),
          axis.ticks = element_blank()
      )+
    guides(colour = guide_legend(nrow = 3))

  ggsave("01_SIMULACION/RESULTADO/GRAFICAS/INDICADORES_131124/VARIABLES/01_Circular_Fac.png")


  #====================================
  # RADAR
  #====================================

  fig_fac <- plot_ly(type = 'scatterpolar',fill = 'toself')
  fig_fac <- fig_fac %>%
    add_trace(
      r = (df_Fac$PROM)*100,
      theta =str_wrap(paste0(df_Fac$INDICADOR,"_",df_Fac$cv_fac),27) ,
      name = df_Fac$Facilitador,
      text=paste(round(df_Fac$PROM,4)*100,"%",sep=""),
      textfont = list(color = "black", size = 10),
      width = 1200, height = 600, showlegend = TRUE
      #color=df_Fac$INDICADOR
    )%>%
    layout(title = list(text ="Valor de los indicadores",y=0.99,x=0.5,font = font_title),
           autosize = T,
           margin=list( l = 50, r = 50, b = 100, t = 100,  pad = 4),
           legend = list(orientation = 'h',font = font_leg,xanchor = "center",x = 0.5),
           polar=list(
             radialaxis =list(
               angle = 90,ticksuffix = '%',
               tickangle = 90,tickvals=seq(0,100,10),
               ticktext = "%",
               range = c(0, 100)
             )
           )
    )
  fig_fac

  save_image(fig_fac, "01_SIMULACION/RESULTADO/GRAFICAS/INDICADORES_131124/VARIABLES/01_Radar_Fac.png")

  #====================================
  #LOLLIPOP
  #====================================

  #options(repr.plot.width =9, repr.plot.height =9)

  jpeg("01_SIMULACION/RESULTADO/GRAFICAS/INDICADORES_131124/VARIABLES/01_lollipop_Fac.png",
       width = 1080, height = 1080, pointsize = 300, quality = 100, bg = "white")

 ggplot(df_Fac, aes(x=str_wrap(INDICADOR,30), y=round(PROM,4)*100,label=format(round(PROM,4)*100,nsmall=2))) +
   #geom_bar(stat='identity', aes(fill=CONFIABILIDAD), width=.5)+
   geom_point(stat='identity', aes(col=Facilitador), size=20) +
   geom_text(color="black", size=4) +
   #scale_color_manual(name="Cofiabilidad",labels = c("Alta", "Media","Baja"),values = c("Alta"="#01ABAA","Media"="#00ba38","Baja"="red")) +
   #geom_text(aes(label=etiquetar_numero(round(PROM,1),2,etiquetar="")),color="black", size=2,vjust=0.5, hjust=-0.5) +

   labs(title="Resultados de los indicadores",subtitle=paste("Facilitadores")) +
   scale_y_continuous(limits = c(20,80),breaks = seq(from =20, to = 80, by = 10))+
   coord_flip()+
    #ylim(c(70, 105)) +
   theme(
     plot.margin = unit(c(1,1,1,1), "cm"),
     axis.text.x = element_text(size =12,vjust=0.5, hjust=1,angle = 0),
     axis.text.y = element_text(size =12,vjust=0.5,hjust=1),
     legend.title = element_text(size=12),
     legend.text = element_text(size=12),
     legend.key.height= unit(0.5, 'cm'),
     legend.key.width= unit(0.5, 'cm'),
     axis.title.x = element_blank(),
     axis.title.y = element_blank(),
     plot.title = element_text(size =14),
     plot.subtitle = element_text(size =12)
   )+
   guides(color = guide_legend(title="Indicadores",override.aes = list(size = 1)))

 dev.off()

 df_Fac$Porcentaje<-round(df_Fac$PROM*100,2)
 df_Fac$Indicador<-paste(df_Fac$INDICADOR,df_Fac$cv_fac,sep="_")


 ggdotchart(df_Fac, x = "Indicador", y = "Porcentaje",
            color = "Facilitador",                                # Color by groups
            palette =sample(colores, 7), # Custom color palette
            sorting = "none",                       # Sort value in descending order
            add = "segments",                             # Add segments from y = 0 to dots
            rotate = TRUE,                                # Rotate vertically
            group = "Facilitador",                                # Order by groups
            dot.size = 6,                                 # Large dot size
            label = round(df_Fac$Porcentaje),                        # Add mpg values as dot labels
            font.label = list(color = "white", size = 9,
                              vjust = 0.5),               # Adjust label parameters
            ggtheme = theme_pubr()                        # ggplot2 theme
 )



 #ggsave("01_SIMULACION/RESULTADO/GRAFICAS/INDICADORES/VARIABLES/01_lollipop_Fac.png")

 library(webr)

 #tiff("00_CATI/RESULTADO/GRAFICAS/INDICADORES/01_PieDonut_Fac1.png",width=1600, height=1200)

 jpeg("01_SIMULACION/RESULTADO/GRAFICAS/INDICADORES/INDICADORES_131124/01_PieDonut_Fac1.png",
      width = 1080, height = 1080, pointsize = 300, quality = 100, bg = "white")

  PieDonut(df_Fac, aes(cv_fac, INDICADOR,count=PROM),
          family="serif",
          donutLabelSize = 4.5,
          labelposition=2,
          pieLabelSize=8,
          start = 120,
          titlesize=7,
          title = "Participación de los Facilitadores",
          ratioByGroup = FALSE,
          explode = 7
          #explodeDonut=TRUE,
          #selected = c(3,6,10,14,18,22,25),
          )


  jpeg("01_SIMULACION/RESULTADO/GRAFICAS/INDICADORES_131124/VARIABLES/01_PieDonut_Fac1.png",
       width = 1080, height = 1080, pointsize = 300, quality = 100, bg = "white")

#===========================================================
#Es al mejor forma, agregando los promedio en las etiquetas
#===========================================================
  PieDonut<-df_Fac %>%
    mutate(indica = paste0(str_wrap(INDICADOR,30), "\n", round(PROM*100,2))) %>%
    mutate(Fac = paste0(str_wrap(Facilitador,12), "\n", round(mean(PROM),4)*100),
           .by = cv_fac)#%>%

    PieDonut(PieDonut, aes(Fac, indica, count=PROM),
             title = "Participación de los Facilitadores",
             showRatioDonut = F, showRatioPie = F, showPieName = F ,
             donutLabelSize=3,
             ## if you want more labels, but it will get messy
             # showRatioThreshold = 0.001,
             r0 = 0.05, r1 = 0.5, r2 = 0.9,
             titlesize = 4, start = 3.5
            )

  dev.off()


df<-unique(INDICADORES[INDICADORES$cv_fac!="00",c("INDICADOR","PROM_G")])

#====================================
#Polar
#====================================

data<-df_Fac
data <- data[order(data$cv_fac),]
data$orden <- ave(data$INDICADOR,data$cv_fac,FUN = seq_along)

#data<-data %>%arrange(cv_fac,orden)

data$order<-as.character(data$order)

color<-c("1"="#368f88","2"="#160f29","3"="#DDBEA8","4"="#FF6666")
color2<-c("1"="#002642","2"="#840032","3"="#E59500","4"="#E5DADA")
color3<-c("01"="#002642","02"="#840032","03"="#E59500","04"="#E5DADA","05"="red","06"="blue","07"="pink")

color4<-c("Manuel Gerardo Cossí Reyes"="#002642",
          "Jorge Alejandro Reyes Eguren"="#840032",
          "Juan Ramón Mena"="#E59500",
          "Maritza González Huitrón"="#E5DADA",
          "Laura Noemí Guzmán Moreno"="red",
          "Cecilia Martinez Serrano"="blue",
          "María Fernanda Salina Álvarez"="pink")

data$id<-seq(1,nrow(data))
sample_numer<-nrow(data)
angle<-90-360*(data$id-0.5)/sample_numer
data$hjust<-ifelse(angle<=90,1,0)
data$angle<-ifelse(angle<=90, angle+180,angle)

#jpeg("01_SIMULACION/RESULTADO/GRAFICAS/INDICADORES/VARIABLES/01_Polar_Fac.png",
     #width = 1080, height = 1080, pointsize = 300, quality = 100, bg = "white")

ggplot(data, aes(x=as.factor(id),y=round(PROM*100,2),fill=Facilitador))+
  geom_bar(stat = "identity",alpha=1)+
  scale_fill_manual(values = color4)+
  geom_text(aes(label=round(PROM*100,2),family = "sans-serif"),position = position_stack(vjust = 0.9),size=2)+
  ylim(-50,100)+
  theme_minimal()+
  coord_polar()+
  labs(title="Valor de los indicadores por Facilitador", y = NULL, x = NULL, color = NULL)+
  theme(
    #legend.position = "none",
    legend.position="bottom",
    legend.text=element_text(size=6),
    legend.title=element_blank(),
    text=element_blank(),
    panel.border=element_blank(),

    #plot.title=element_text(size=10, hjust=0.5, face='bold'),
    axis.text.y = element_blank(),
    axis.text.x = element_blank(),
    axis.title.x = element_blank(),
    panel.grid.minor = element_blank(),
    axis.ticks.y = element_blank(),
    axis.ticks = element_blank(),

    axis.text = element_blank(),
    axis.title =  element_blank(),
    panel.grid =  element_blank()#,
    #plot.margin = unit(rep(-0.35,10),"cm")
  )+
geom_text(data=data,
             aes(x=id,y=round(PROM*100,2)+10,label=str_wrap(INDICADOR,20),hjust=hjust,family = "sans-serif"),
             color="black",
             fontface="bold",
             alpha=0.6,
              size=2.5,
             angle=data$angle,
             inherit.aes = FALSE)+
guides(colour = guide_legend(nrow = 3))

ggsave("01_SIMULACION/RESULTADO/GRAFICAS/INDICADORES_131124/VARIABLES/01_Polar_Fac.png")

dev.off()




#Referencia: https://www.youtube.com/watch?v=IMTxF861-Nk

#====================================
# Barra
#====================================

df <- df_Fac[order(df_Fac$INDICADOR),]
df$PROM_IND <- ave(df$PROM,df$INDICADOR ,FUN = mean)

df <- df[order(df$cv_fac),]
df$PROM_FAC <- ave(df$PROM,df$cv_fac ,FUN = mean)


bullet_colors <- c("#E9FFE3", "#A3D694", "#61AB40", "#318100")

#bullet_colors <- c("#f7f7f7","#e7d4e8","#c2a5cf","#9970ab") #https://www.infocaptor.com/docs/infocaptor/visualizations/how-to-create-horizontal-bullet-chart

names(bullet_colors) <- c("Poor", "Ok", "Good", "Excellent")


df <- df %>% mutate(rank = case_when(
  0.0 <= PROM_FAC & PROM_FAC <= 0.6 ~ "Poor",
  0.6 < PROM_FAC  & PROM_FAC <= 0.7 ~ "Ok",
  0.7 < PROM_FAC & PROM_FAC <= 0.8 ~ "Good",
  0.8 < PROM_FAC & PROM_FAC <= 1.0 ~ "Excellent"
))

df$Porcentaje<-round(df$PROM_FAC*100,2)
df<-df[!duplicated(df[,c("Facilitador")]), ]


ggplot(df, aes(str_wrap(Facilitador,20), y = Porcentaje)) +
  geom_bar(data = df,aes(x = str_wrap(Facilitador,20), y = Porcentaje, fill = rank), stat = "identity",
           position = "stack") +
  geom_bar(data = df,aes(x =str_wrap(Facilitador,20), y = Porcentaje), fill = "#2297E6", width = 0.15,
           stat = "identity") +
  scale_fill_manual(values = bullet_colors) +
  scale_y_continuous(lim=c(0,105),breaks=seq(0,100,by=10))+
  coord_flip(expand = FALSE)+
geom_text(aes(label=Porcentaje),hjust = -0.5, size = 2,fontface = "bold", family = "italic",
          position = position_dodge(width = 1),inherit.aes = TRUE)+
  labs(title="Valor de indicador por Facilitador",x="",y="")+
theme(
  #axis.text.y = element_blank(),
  legend.position = "none",
  axis.title = element_text(size=8, hjust=0.1, face='italic'),
  axis.text.y = element_text(size=6, hjust=0.1, face='italic'),
  axis.text.x = element_text(size=6, hjust=0.1, face='italic'),
  axis.title.x = element_blank(),
  panel.grid.minor = element_blank(),
  axis.ticks.y = element_blank(),
  axis.ticks.x = element_blank()
)+
  guides(colour = guide_legend(nrow = 3))

ggsave("01_SIMULACION/RESULTADO/GRAFICAS/INDICADORES_131124/VARIABLES/00_barr_fac.png")




#https://medium.com/@victorallan/create-stunning-circular-bar-plots-in-r-ggplot2-with-minimal-code-28e2aaf6fe36
  #https://www.gettingbluefingers.com/tutorials/RadarPizzaChart
  #https://r-graph-gallery.com/web-circular-barplot-with-R-and-ggplot2.html
  #https://rpubs.com/PaulWilliamson/5795
  #https://r-graph-gallery.com/143-spider-chart-with-saveral-individuals.html
  #https://t-redactyl.io/blog/2016/01/creating-plots-in-r-using-ggplot2-part-4-stacked-bar-plots.html
  #https://towardsdatascience.com/5-ways-to-effectively-visualize-survey-data-using-r-89928bf08cb2
 #Lista de gráficos: https://help.salesforce.com/s/articleView?id=sf.bi_visualize.htm&type=5
#Circular: https://stackoverflow.com/questions/73333971/3-layer-donut-chart-in-r


##############################################################################
#MINERIA DE TEXTO
##############################################################################

#====================================
#Nuve de palabras
#====================================
column_name<-catalago_new[catalago_new$TIPO_DE_RESPUESTA %in% c("Abierta"),"V_Mnemonicos"]

df_text<-tab_cod_fin[,column_name]
df_text<-df_text %>% select_if(~ any(!is.na(.)))

#text<-melt(df_text, measure.vars = column_name,variable.name = "Mnemonico", value.name = "texto")
df_texto<-list()
for(colunms in colnames(df_text)){
  text<-df_text[,colunms] %>% na.omit()
  text<-paste(as.vector(unlist(text)),collapse=" ")
  #text<-as.vector(unlist(lapply(df_text[,colunms], as.vector)))
  df_texto[[colunms]] <- data.frame(id=colunms,texto=paste(text, collapse=" "))
}
list_text<-do.call(rbind, unique(df_texto))


list_text$texto<-tolower(list_text$texto)
list_text<-list_text[list_text$texto %!in% c(NA,"ninguna","ningu"),]
list_text <- list_text %>%na.omit()

words <- paste(c(NA,"ninguna","ninguno","ningu"), collapse = "|")
list_text$texto<-trimws(gsub(words, "\\1", list_text$texto))

write.csv(data.frame(list_text), file=paste(RESUL,"GRAFICAS/TEXTO/df_texto.csv",sep="/"))


library(caret)
library(tm)
library(textstem)
library(wordcloud)
library(lexicon)
library(SnowballC)
library(RColorBrewer)
require(tidyverse)
require(magrittr)
require(ggwordcloud)
library(RWeka)
library(syuzhet)



#Tratamiento

topwords <- read.table(file = "C:/Users/german.galdamez/OneDrive - INEGI/EVALUACION_2024/TRATAMIENTO/Scripts/spanish.txt", header = TRUE)
topwords<-str_trim(stri_trans_general(topwords, id="Latin-ASCII"))
topwords<-gsub('#\\S+','',topwords)

#==================================================================
#Para ngrams=1, es decir de una palabra
#==================================================================

Freq<-Corpus(list_text$texto,
                  lang="spanish",
                  mystopwords=topwords,
                  textStemming=TRUE,
                  textLemmatization=FALSE,
             n_grams=1)

ggplot(data = Freq,
       aes(label = word, size = freq, col = as.character(freq))) +
  geom_text_wordcloud(rm_outside = TRUE, max_steps = 1,
                      grid_size = 1, eccentricity = .9)+
  scale_size_area(max_size = 14)+
  scale_color_brewer(palette = "Paired", direction = -1)+
  labs(title="Análisis de  texto")+
  theme_void()+
  theme(
    axis.text.x = element_text(size =7,vjust=0.5, hjust=1,angle = 45),
    axis.text.y = element_text(size =7,vjust=0.5,hjust=1),
    legend.title = element_text(size=8),
    legend.text = element_text(size=8),
    legend.key.height= unit(0.5, 'cm'),
    legend.key.width= unit(0.5, 'cm'),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    plot.title = element_text(size =10),
    plot.subtitle = element_text(size =8)
  )

ggsave("00_CATI/RESULTADO/GRAFICAS/TEXTO/wordcloud1_unigrama.png",width = 100, height = 60, units = "mm")


set.seed(1234)
tiff("00_CATI/RESULTADO/GRAFICAS/TEXTO/wordcloud2_unigrama.tiff", units="in", width=10, height=7.5, res=500, compression = 'none')
wordcloud(words = Freq$word, freq = Freq$freq, min.freq = 1,
          max.words=50, random.order=F, rot.per=0.35,
          colors=brewer.pal(8, "Dark2"),
          title="Análisis de texto")
dev.off()

ggplot(head(Freq,10), aes(reorder(word,freq), freq)) +
  geom_bar(aes(fill = word),stat = "identity") + coord_flip() +
  xlab("Bigrams") + ylab("Frecuencias") +
  ggtitle("Las palabras más representativas (Unigramas)")+
  guides(fill="none")+
  theme(
    axis.text.x = element_text(size =8,vjust=0.5, hjust=1),
    axis.text.y = element_text(size =8,vjust=0.5,hjust=1),
    legend.title = element_text(size=8),
    legend.text = element_text(size=8),
    legend.key.height= unit(0.5, 'cm'),
    legend.key.width= unit(0.5, 'cm'),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    plot.title = element_text(size =12),
    plot.subtitle = element_text(size =8)
  )

ggsave("00_CATI/RESULTADO/GRAFICAS/TEXTO/Unigramas.png")

library("ggthemes")

Freq$word<-factor(Freq$word,levels=unique(as.character(Freq$word)))

ggplot(Freq[1:15,], aes(x=word,y=freq))+
  geom_bar(stat="identity", fill='darkred')+
  coord_flip()+
  theme_gdocs()+
  geom_text(aes(label=freq),colour="white",hjust=1.25, size=4.0)+
  xlab("") + ylab("Frecuencias") +
  ggtitle("Las palabras más representativas (Unigramas)")+
  theme(
    axis.text.x = element_text(size =8,vjust=0.5, hjust=1),
    axis.text.y = element_text(size =8,vjust=0.5,hjust=1),
    legend.title = element_text(size=8),
    legend.text = element_text(size=8),
    legend.key.height= unit(0.5, 'cm'),
    legend.key.width= unit(0.5, 'cm'),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    plot.title = element_text(size =12),
    plot.subtitle = element_text(size =8)
  )

ggsave("00_CATI/RESULTADO/GRAFICAS/TEXTO/Unigramas2.png")
#==================================================================
#Para ngrams=2, es decir de una palabra
#==================================================================

Freq2<-Corpus(list_text$texto,
             lang="spanish",
             mystopwords=topwords,
             textStemming=TRUE,
             textLemmatization=FALSE,
             n_grams=2)


set.seed(1234)
tiff("00_CATI/RESULTADO/GRAFICAS/TEXTO/wordcloud_bigrama.tiff", units="in", width=10, height=7.5, res=500, compression = 'none')
wordcloud(words = Freq2$word, freq = Freq2$freq, min.freq = 1,
          max.words=50, random.order=F, rot.per=0.35,
          colors=brewer.pal(8, "Dark2"),
          main="Análisis de texto")
dev.off()




ggplot(head(Freq2,10), aes(reorder(word,freq), freq)) +
  geom_bar(aes(fill = word),stat = "identity") + coord_flip() +
  xlab("Bigrams") + ylab("Frecuencias") +
  ggtitle("Las palabras más representativas (bigramas)")+
  guides(fill="none")+
  theme(
    axis.text.x = element_text(size =8,vjust=0.5, hjust=1),
    axis.text.y = element_text(size =8,vjust=0.5,hjust=1),
    legend.title = element_text(size=8),
    legend.text = element_text(size=8),
    legend.key.height= unit(0.5, 'cm'),
    legend.key.width= unit(0.5, 'cm'),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    plot.title = element_text(size =12),
    plot.subtitle = element_text(size =8)
  )

ggsave("00_CATI/RESULTADO/GRAFICAS/TEXTO/Bigramas.png")



#########################################################

#########################################################

text<-str_trim(stri_trans_general(list_text$texto, id="Latin-ASCII")) #Covertir a minusculas
text <- stri_replace_all(text, "", regex = "<.*?>") # remove html tags
text <- stri_trim(text) # strip surrounding whitespace
text <- stri_trans_tolower(text) # transform to lower case
text


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
  stri_replace_all(x, "", regex = "<.*?>")
  stri_trim(x)
  stri_trans_tolower(x)
  #str_replace_all(x, "[[:punct:]]", " ")
  #str_replace_all(x, "[^[:alnum:]]", " ")
}

text<-text_preprocessing(text)

library(quanteda)
text <- tokens(text)
text <- tokens_tolower(text)
text <- tokens_wordstem(text)
sw <- stopwords("spanish")
text<-tokens_remove(text, sw)

text<-paste(as.vector(unlist(text)), collapse = " ")
text<-trim(text)
text <- gsub("[[:alnum:]._%+-]+@[[:alnum:].-]+\\.[[:alpha:]]{2,}", "", text)

sentimientos_df <- get_nrc_sentiment(text, lang="spanish")
#palabras_tristeza <- text[sentimientos_df$sadness> 0]

nube_emociones_vector <- c(
  paste(text[sentimientos_df$anticipation> 0], collapse = " "),
  paste(text[sentimientos_df$joy > 0], collapse = " "),
  paste(text[sentimientos_df$trust > 0], collapse = " "),
  paste(text[sentimientos_df$fear > 0], collapse = " ")
  )

nube_emociones_vector <- c(
  paste(text[sentimientos_df$negative> 0], collapse = " "),
  paste(text[sentimientos_df$positive > 0], collapse = " ")
)

nube_emociones_vector <- iconv(nube_emociones_vector, "latin1", "UTF-8")

#nube_corpus <- Corpus(VectorSource(nube_emociones_vector))
nube_corpus <- VCorpus(VectorSource(nube_emociones_vector))
nube_corpus<- tm_map(nube_corpus, content_transformer(tolower)) #Convertir minusculas
nube_corpus<- tm_map(nube_corpus, stripWhitespace) # Quitar doble espacio
nube_corpus<- tm_map(nube_corpus, removePunctuation,preserve_intra_word_contractions = FALSE,
                     preserve_intra_word_dashes = TRUE) # Quitar puntuaciones
nube_corpus<- tm_map(nube_corpus, removeNumbers) # Quitar números
nube_corpus

#nube_corpus <- SimpleCorpus(VectorSource(unlist(lapply(nube_emociones_vector, as.character))))

nube_tdm <- TermDocumentMatrix(nube_corpus)
nube_tdm <- as.matrix(nube_tdm)
head(nube_tdm)

colnames(nube_tdm) <- c('anticipation', 'joy', 'trust', 'fear')
head(nube_tdm)

colnames(nube_tdm) <- c('negative', 'positive')
head(nube_tdm)

set.seed(124)
comparison.cloud(nube_tdm, random.order = FALSE,
                 colors = c("green", "red", "orange", "blue"),
                 title.size = 1, max.words = 50, scale = c(2.5, 1), rot.per = 0.4)

entimientos_valencia <- (sentimientos_df$negative *-1) + sentimientos_df$positive
simple_plot(sentimientos_valencia)


library("SentimentAnalysis")

all.tdm<-TermDocumentMatrix(nube_corpus,
                            control=list(weighting=weightTfIdf, removePunctuation =
                                           TRUE,stopwords=stopwords(kind='es')))

all.tdm.m<-as.matrix(all.tdm)
colnames(all.tdm.m)<-c('positive','negative')

comparison.cloud(all.tdm.m, max.words=100,
                 colors=c('darkgreen','darkred'))


#https://www.r-bloggers.com/2021/05/sentiment-analysis-in-r-3/
#Sentimiento: https://programminghistorian.org/en/lessons/sentiment-analysis-syuzhet
