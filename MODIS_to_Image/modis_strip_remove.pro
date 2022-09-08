pro modis_strip_remove,infile,aqua = aqua,terra=terra,smooth=smooth,ksize=ksize
;; This routuine is used to remove the strip noise of MODIS 5th band (1240nm)
;; Author: Lianbo Hu
;; June 28,2011, lianbo.hu@gmail.com
;; update: adding MODIS band 2 nosie removal on Feb.23,2017
 Fillvalue = 32700l
 print,''
 print,'The procedure begin to remove the strip noise in the MODIS 5th band (1240nm)'
 print,''


 ;print,''
 ;bak_dir = './BAK'
 ;print,'The backup directory is: '+bak_dir
 


     print,"Removing noise in Band 5 "
     print,''
     fid = hdf_sd_start(infile,/rdwr)
;;;;;; ---------------Band 1240------------------------------------ 
     var_index=hdf_sd_nametoindex(fid,'CorrRefl_05')
     varid_1240=hdf_sd_select(fid,var_index)
     hdf_sd_getdata,varid_1240,dn1240
     dims = size(dn1240)  
     ncol = dims[1] & nrow = dims[2]
     
     if keyword_set(aqua) then begin
        idx_bad=where(dn1240[10,*] gt Fillvalue,nbad,comp=idx_good,nc=ngood)
        if nbad gt 0 then $
            for ni=0,ncol-1 do dn1240[ni,idx_bad] = interpol(dn1240[ni,idx_good],idx_good,idx_bad,/spline) $
        else print,'No stripe line in Aqua Band 1240'
     endif
    
;;   The differencee of noise removal for Terra band 5 is to replace two lines value close to stripe line
     if keyword_set(terra) then begin    
        bad = bytarr(nrow)
        idx_bad = where(dn1240[10,*] gt FillValue,nlines)
        if nlines gt 0 then begin
           idx_bad_1 = idx_bad -1
   	   idx_bad_2 = idx_bad+1
   	   if idx_bad_1[0] lt 0 then idx_bad_1[0] = 0
   	   if idx_bad_2[-1] gt nrow-1 then idx_bad_2[-1] = nrow-1
  	   bad[idx_bad] = 1 & bad[idx_bad_1] = 1 & bad[idx_bad_2] = 1
      
  	   idx_bad = where(bad eq 1,nbad,comp = idx_good,nc=ngood) 
    	   for ni=0,ncol-1 do dn1240[ni,idx_bad] = interpol(dn1240[ni,idx_good],idx_good,idx_bad,/spline)
        endif else print,'No stripe lines in Terra Band 1240'
      endif
    
;;;------------------------- Band 1640--------------------
     var_index=hdf_sd_nametoindex(fid,'CorrRefl_06')
     varid_1640=hdf_sd_select(fid,var_index)
     hdf_sd_getdata,varid_1640,dn1640
     dims = size(dn1640)  
     ncol = dims[1] & nrow = dims[2]
     idx_bad=where(dn1640[10,*] gt Fillvalue,nbad,comp=idx_good,nc=ngood)
     if nbad gt 0 then $
        for ni=0,ncol-1 do dn1640[ni,idx_bad] = interpol(dn1640[ni,idx_good],idx_good,idx_bad,/spline) $
     else print,'No stripe line in Aqua Band 1640'
;;;;--------------------  Band 2130 ----------------
     var_index=hdf_sd_nametoindex(fid,'CorrRefl_07')
     varid_2130=hdf_sd_select(fid,var_index)
     hdf_sd_getdata,varid_2130,dn2130
     dims = size(dn2130)  
     ncol = dims[1] & nrow = dims[2]
     idx_bad=where(dn2130[10,*] gt Fillvalue,nbad,comp=idx_good,nc=ngood)
     if nbad gt 0 then $
        for ni=0,ncol-1 do dn2130[ni,idx_bad] = interpol(dn2130[ni,idx_good],idx_good,idx_bad,/spline) $
     else print,'No stripe line in Aqua Band 2130'
    
;;   The differencee of noise removal of Terra band 5 is to reset values adjacet to stripe line
 
      if keyword_set(smooth) then begin
        if n_elements(ksize) eq 0 then ksize = 3
        dn1240 = median(dn1240,ksize)
        dn1640 = median(dn1640,ksize)
        dn2130 = median(dn2130,ksize)
     endif
       
     hdf_sd_adddata,varid_1240,dn1240            
     hdf_sd_adddata,varid_1640,dn1640            
     hdf_sd_adddata,varid_2130,dn2130            
     hdf_sd_endaccess,varid_1240
     hdf_sd_endaccess,varid_1640
     hdf_sd_endaccess,varid_2130
     dn1240 = 0 & dn1640 = 0 & dn2130 = 0

     ;;; removing noise in MODIS band 2
     if keyword_set (terra) then begin
      print,'Removing stripe outliers in Band 2 of Terra.'
      print,''
      
      thd1 = 10 
      thd2 = 1000 ;; exclude land and cloud pixels
      
      var_index_nir = hdf_sd_nametoindex(fid,'CorrRefl_02')
      varid_nir = hdf_sd_select(fid,var_index_nir)
      hdf_sd_getdata,varid_nir,dn859
      dims = size(dn859)
      ncol = dims[1] & nrow = dims[2]
     
     data_diff1 = shift_diff(dn859,direction=1)
     data_diff2 = shift_diff(dn859,direction=3)
     data_diff3 = shift_diff(dn859,direction=4)
     data_diff4 = shift_diff(dn859,direction=6)
     idx_outlier = where(data_diff1 gt thd1 and data_diff2 gt thd1 and data_diff3 gt thd1 and $
                         data_diff4 gt thd1 and dn859 lt thd2,npoints)
     data_diff1 = 0 & data_diff2 = 0 & data_diff3 = 0 & data_diff4 = 0
    if npoints gt 100 then begin
        mask = intarr(ncol,nrow)
        mask[idx_outlier] = 255
        num = intarr(nrow)
        for ni=0,nrow-1 do begin
            idx = where(mask[*,ni] eq 255,count)
            num[ni] = count
        endfor
       maxnum = max(num,idx_maxnum)
       ;print,maxnum,idx_maxnum
     
	idx1 = idx_maxnum -11
	idx2 = idx_maxnum+11
 	if idx1 lt 0 then idx1 = idx_maxnum+29
 	if idx2 gt nrow-1 then idx2 = idx_maxnum -29
  	if num[idx1] gt num[idx2] then idx_maxnum2 = idx1 else idx_maxnum2 = idx2

  ;; identifing outlier lines
  	bad_line = bytarr(nrow)
	for ni=0,nrow-1 do $
   	     if (ni-idx_maxnum) mod 40 eq 0 or (ni-idx_maxnum2) mod 40 eq 0 then bad_line[ni] = 1
  
  	idx_bad = where(bad_line eq 1,nbad,comp=idx_good,nc=ngood)
  	if nbad gt 0 then  $
    	for ni=0,ncol-1 do dn859[ni,idx_bad] = interpol(dn859[ni,idx_good],idx_good,idx_bad,/spline) 
	hdf_sd_adddata,varid_nir,dn859
    endif else print,'No outlier line is found in Terra Band2' 
      hdf_sd_endaccess,varid_nir  
      hdf_sd_end,fid
  endif
          
 end
