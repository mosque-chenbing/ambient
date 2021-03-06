(defun extractjson(material)
  (extract material 'BRACEL))

(defun  handlejson (json)
  (progn
    (print (jgetstring
            (jgetobject
             (jgetobject             
              (jgetobject             
               (jgetobject             
                (jgetobject json 'as)
                (quote as_response))
               (quote as_result))
              (quote results))
             (quote num_found))))
    json))

(defun handlematerial(material)
  (if (eq material nil)
      nil
    (print material)))

(defun  get (socket)
  (send socket (concat (lineconcat (list (quote GET /?debug_info=as&debug_id=123456&wwsy=yes&rows=60&start=0&wt=json&q=α5α0αn5700u&fl=vendor_Name,partnumber,brand_Name,auxdescription,three_groupName,three_groupExtName,author,isbn,unit_searchable_attr,title,two_groupName,threeGroupIds,short_brand_Id HTTP/1.0) 
                                         (quote Host: 127.0.0.1) 
                                         (quote U-ApiKey:8b6c51b8a18ccbdae3c7ac74169ec3da) 
                                         (quote Content-Length: 0)
                                         (quote User-Agent: http_get) 
                                         (quote Content-Type: application/json) 
                                         (quote Accept: */*) 
                                         (quote Accept-Language: utf8) 
                                         (quote Accept-Charset: iso-8859-1,*,utf-8) 
                                         (quote Authorization: Basic YWRtaW46YWRtaW4=) 
                                         (quote Connection: Keep-Alive)))
                       'LINE
                       'LINE)))

(defun routine(pid)
  (progn
    (print 'routine)
    (print pid)
    nop))

(defun  worker(socket)
  (progn
    (print 'worker)
    (handlematerial
     (recv socket))
    (close socket)
    (routine (pget))))

(defun  network()
  (get (connect (quote 172.19.59.15:8888))))

(defun dispatch()
  (progn
    (pcreate 1 'worker (network))
    (sleep 1)
    (dispatch)))

(pjoin (pcreate 1 'dispatch))
