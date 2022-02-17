pro modis_l2, infile,SeaDAS=SeaDAS,success = success,merge=merge,ext=ext,l2par=l2par,ys=ys
;; This routine process modis L0 file to generate L1B file
;; infile must be L0 file or L0.bz2 file

success = 1
skipnext = 0

if ~keyword_set(SeaDAS) then SeaDAS="/opt/seadas-7.2"
if ~file_test(SeaDAS,/directory) then begin
    print,'SeaDAS folder is not in '+SeaDAS
    success = 0 & return
endif
SeaDAS1 = SeaDAS+'/ocssw/scripts/'
SeaDAS2 = SeaDAS+'/ocssw/bin/'
;; test if the input file is bz2 file
l2proname='sst,chlor_a,ipar'

filename = file_basename(infile)

modis_name_extract,filename,L0_LAC=L0_LAC,L1A_LAC=L1A_LAC,L1B_LAC = L1B_LAC,L1B_HKM = L1B_HKM,$
  L1B_QKM = L1B_QKM,GEO_file = GEO_file,L2_LAC=L2_LAC

if keyword_set(merge) then begin
   modis_next_grandule,filename,next_file
   if file_test(next_file) then begin
      mergefile=strmid(filename,0,14)+'.merge.L0_LAC'
      spawn,'cat '+filename+' '+next_file+'>'+mergefile
      file_delete,filename,next_file
      file_move,mergefile,filename
   endif
 endif

if ~file_test(L0_LAC) then begin
  print,filename+' is corruped and failed to unzip.'
  success = 0 &    return
endif

;; processing to L1A and L1B
 cmd1 = SeaDAS1+'modis_L1A.py '+L0_LAC+' -o '+L1A_LAC
 cmd2 = SeaDAS1+'modis_GEO.py '+L1A_LAC+' -o '+GEO_file
 cmd3 = SeaDAS1+'modis_L1B.py '+ L1A_LAC+' '+GEO_file+' -o '+L1B_LAC $
           +' -q '+L1B_QKM+' -k '+L1B_HKM
if n_elements(l2par) eq 0 and keyword_set(ys) then $
    cmd4 = SeaDAS2+"l2gen ifile="+L1B_LAC+' geofile='+GEO_file+' ofile1='+L2_LAC+" l2prod1="+l2proname+$
        " proc_land=0 maskland=1 brdf_opt=0"+" north=38 south=32 west=118 east=124" 
if n_elements(l2par) eq 0 and ~keyword_set(ys) then $
     cmd4 = SeaDAS2+"l2gen ifile="+L1B_LAC+' geofile='+GEO_file+' ofile1='+L2_LAC+" l2prod1="+l2proname+$
        " proc_land=0 maskland=1 brdf_opt=0"
if n_elements(l2par) ne 0 then  cmd4 = SeaDAS2+"l2gen par="+l2par
 
 ;;'Processing modis L0 to L1A'
  print,cmd1 &  spawn,cmd1
 
 if ~file_test(L1A_LAC) then begin
       print,'L1A file is failed to process.The program will be returned.'
       success = 0 & return
  endif
  
  ;;print,'Processing L1A to GEO'
  print,cmd2 & spawn,cmd2
  if ~file_test(GEO_file) then begin
       print,GEO_file+' is not processed.The program will be returned.'
       success = 0 &  return
  endif

 ;; print,'Processing L1A to L1B'
  print,cmd3 & spawn,cmd3
  if ~file_test(L1B_LAC) then begin
       print,'L1B file is not processed. The program will be returned'
       success = 0 & return
   endif
;; Processing L1B to L2
   if ~strcmp(ext,'ecs') then print,cmd4 & spawn,cmd4
   if ~file_test(L2_LAC) then begin
      print,'L2 file is not processed. The program will be returned'
     success = 0 & return
   endif

 print, "Processing MODIS L0-L2 is finished!"
end
