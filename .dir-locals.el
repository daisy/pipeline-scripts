((nil
  (compile-command . (format "cd %s && mvn clean install"
                             (locate-dominating-file buffer-file-name "pom.xml")))))




