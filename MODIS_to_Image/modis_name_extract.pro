pro modis_name_extract,infile,L0_LAC=L0_LAC,L1A_LAC=L1A_LAC,L1B_LAC = L1B_LAC,L1B_HKM = L1B_HKM,$
                    L1B_QKM = L1B_QKM,GEO_file = GEO_file, M02_LAC=M02_LAC, M02_HKM=M02_HKM, $
                    M02_QKM = M02_QKM,M03_GEO=M03_GEO,basename=basename,L2_LAC=L2_LAC
    
    ;; extact modis names from MODIS L0 or bz2 file
    filename = file_basename(infile)
    
    first_letter = strmid(filename,0,1)
    if strcmp(first_letter,'T') or strcmp(first_letter,'A') then begin
      ; print,'The MODIS L0 file format is not PDS.'
       if strcmp(first_letter,'T') then prefix = 'MOD' 
       if strcmp(first_letter,'A') then prefix = 'MYD'
       basename = strmid(filename,0,14)
       L0_LAC = basename+'.L0_LAC'
    endif
    
    if strcmp(first_letter,'M') then begin
      print,'The MODIS L0 file is PDF format.'
      seven_letter = strmid(filename,6,1)
      if strcmp(seven_letter,'P') then begin
         isensor='A' & prefix = 'MYD'
      endif
      if strcmp(seven_letter,'A') then begin
        isensor='T' & prefix = 'MOD'
      endif
      
      basename = isensor+strmid(filename,7,7)+strmid(filename,15,4)+'00'
      L0_LAC = strmid(filename,0,25)
    endif 
     
    L1A_LAC = basename+'.L1A_LAC'
    GEO_file = basename+'.GEO'
    L1B_LAC = basename+'.L1B_LAC'
    L1B_HKM = basename+'.L1B_HKM'
    L1B_QKM = basename+'.L1B_QKM'
    L2_LAC = basename+'.L2_LAC'
    
    syear = strmid(basename,1,4)
    sdoy = strmid(basename,5,3)
    shh = strmid(basename,8,2)
    smm = strmid(basename,10,2)
    sss = strmid(basename,12,2)
    
    ;; processing time
     spawn,'date +%Y%j%H%M%S',ptime
     ptime = '0000000000000'
    
    M02_LAC = prefix+'02'+'1KM'+'.A'+syear+sdoy+'.'+shh+smm+'.006.'+ptime[0]+'.hdf'
    M02_HKM = prefix+'02'+'HKM'+'.A'+syear+sdoy+'.'+shh+smm+'.006.'+ptime[0]+'.hdf'
    M02_QKM = prefix+'02'+'QKM'+'.A'+syear+sdoy+'.'+shh+smm+'.006.'+ptime[0]+'.hdf
    M03_GEO = prefix+'03'+'.A'+syear+sdoy+'.'+shh+smm+'.006.'+ptime[0]+'.hdf'
    
end
    
