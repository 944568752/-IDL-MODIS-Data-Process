pro modis_mrts,file_mrts,parfile=parfile,infile=infile,outfile=outfile,$
    geofile=geofile,oul=oul,olr=olr
;; this routine process MODIS projection using MRTS tools.
;; By Lianbo Hu on Dec.26,2016
;

if ~file_test(file_mrts) then begin
    print,"MRTS is not exit. Please check "+file_mrts
    return
endif

cmd = file_mrts+' -pf='+parfile+' -if='+infile+' -of='+outfile+' -gf='+geofile
print,cmd
spawn,cmd

end       