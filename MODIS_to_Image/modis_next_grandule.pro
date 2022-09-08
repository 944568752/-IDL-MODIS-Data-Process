pro modis_next_grandule,infile,next_file

;; return the next grandule file name
 first_file = infile
 
 filename = file_basename(infile)
 basename = strmid(filename,0,14)
 

if strcmp(strmid(filename,0,1),'M') then begin
  print,'The MODIS L0 file is PDS format and current program is not support PDS.'
  return
endif

prefix = strmid(basename,0,8)
shh= strmid(basename,8,2)
smm = strmid(basename,10,2)

Case smm of
  '55': begin
        hh_next = fix(shh)+1
        if hh_next lt 10 then shh_next = '0'+strtrim(string(hh_next),2)
        shh_next = strtrim(string(hh_next),2)
        smm_next = '00'
        end
  '00': begin
        smm_next = '05'
        shh_next = shh
        end
   else:begin
        mm_next = fix(smm)+5
        smm_next = strtrim(string(mm_next),2)
        shh_next = shh
        end
Endcase
 suffix = strmid(filename,14,strlen(filename)-14)
 next_file = prefix+shh_next+smm_next+'00'+suffix
end