{ config, lib, pkgs, ... }:

{
  services.nginx.config = ''
    http {
      charset utf-8;
      index index.html index.txt index.json index.geojson index.xml index.gml index.sh;
      include ${pkgs.nginx}/conf/mime.types;

      fastcgi_index index.sh;
      fastcgi_param QUERY_STRING            $query_string;
      fastcgi_param REQUEST_METHOD          $request_method;
      fastcgi_param CONTENT_TYPE            $content_type;
      fastcgi_param CONTENT_LENGTH          $content_length;
      fastcgi_param SCRIPT_FILENAME         $document_root$fastcgi_script_name;
      fastcgi_param SCRIPT_NAME             $fastcgi_script_name;
      fastcgi_param PATH_INFO               $fastcgi_path_info;
      fastcgi_param PATH_TRANSLATED         $document_root$fastcgi_path_info;
      fastcgi_param REQUEST_URI             $request_uri;
      fastcgi_param DOCUMENT_URI            $document_uri;
      fastcgi_param DOCUMENT_ROOT           $document_root;
      fastcgi_param SERVER_PROTOCOL         $server_protocol;
      fastcgi_param GATEWAY_INTERFACE       CGI/1.1;
      fastcgi_param SERVER_SOFTWARE         nginx/$nginx_version;
      fastcgi_param REMOTE_ADDR             $remote_addr;
      fastcgi_param REMOTE_PORT             $remote_port;
      fastcgi_param SERVER_ADDR             $server_addr;
      fastcgi_param SERVER_PORT             $server_port;
      fastcgi_param SERVER_NAME             $server_name;
      fastcgi_param HTTPS                   $https;

      server {
        server_name lahteenmaki.net;
        listen *:80;

        location ~ "^([^?]*)?/index\.sh([?;].*)?$" {
          root /var/www;
          if (-f $request_filename) {
            fastcgi_pass unix:/run/fcgiwrap.sock;
          }
        }

        location ~ "^[^?]+\.sh([?#].*)?" {
          root /var/www;
          fastcgi_pass unix:/run/fcgiwrap.sock;
        }

        location / {
          root /var/www;

          #return 301 https://$host$request_uri;
        }

        location /bus-tre {
          proxy_pass http://api.publictransport.tampere.fi/1_0_2/;
        }
        location /bus-hsl {
          proxy_pass http://api.reittiopas.fi/hsl/prod/;
        }
        location /bus-siri {
          proxy_pass https://siri.ij2010.tampere.fi/ws;
        }
        location /bus-json {
          proxy_pass http://data.itsfactory.fi/siriaccess/vm/json;
        }
      }

      server {
        server_name lahteenmaki.net;
        listen 443 ssl spdy;
        listen [::]:443 ssl spdy;

        #ssl_certificate /var/lib/acme/lahteenmaki.net/fullchain.pem;
        #ssl_certificate_key /var/lib/acme/lahteenmaki.net/key.pem;

        location / {
          root /var/www;
        }
      }
    }
    events {
    }

  '';
}
