#!/bin/bash
#set -x
#root_www
s_directory=(
/usr/share/nginx/my.xunyou.com/application/{log,cache}
/usr/share/nginx/my.xunyou.com/log
/usr/share/nginx/my.xunyou.com/weixin/application/cache
/usr/share/nginx/my.xunyou.com/wein/log
/usr/share/nginx/mall.xunyou.com/application/cache
/usr/share/nginx/mall.xunyou.com/{log,compiled,html}
/usr/share/nginx/mall.xunyou.com/application/views/html
/usr/share/nginx/mall.xunyou.com/shop/proDetail
/usr/share/nginx/www.xunyou.com/app1/templates_c
/usr/share/nginx/www.xunyou.com/app1/system/application/config/act.php 
/usr/share/nginx/www.xunyou.com/{battlegrounds,zt,compiled,log,client,sideboxs,sideboxes,hr,2014hr,banner,58,59,60,61,102,103,133,119,120,121,124,125,126,127,131,145,185,186,189,195,214,209,216,217}
/usr/share/nginx/www.xunyou.com/privilege.shtml
/usr/share/nginx/app.xunyou.com/logs
/usr/share/nginx/rank.xunyou.com/compiled
/usr/share/nginx/rank.xunyou.com/rank
/usr/share/nginx/union.xunyou.com/{log,cache}
/usr/share/nginx/union.xunyou.com/pay/2014/games
/usr/share/nginx/union.xunyou.com/pay/application/cache
/usr/share/nginx/act.xunyou.com/uploads
/usr/share/nginx/act.xunyou.com/wap/uploads
/usr/share/nginx/act.xunyou.com/api/application/{cache,logs}
/usr/share/nginx/act.xunyou.com/wap/applicaiton/{cache,logs}
/usr/share/nginx/gs.xunyou.com/application/cache
/usr/share/nginx/gs.xunyou.com/log
/usr/share/nginx/cs.xunyou.com/htdocs/{upload,log}
/usr/share/nginx/cs.xunyou.com/application/cache
/usr/share/nginx/trade.xunyou.com/log 
/usr/share/nginx/trade.xunyou.com/application/cache
/usr/share/nginx/news.xunyou.com/{g,www,compiled,client,232,254,231,237,238,244,242,243,187,245,257,246,247,255,258,248,250,html}
/usr/share/nginx/g.xunyou.com/{sideboxes,210,219,220,223,251,client,compiled,templates,templates_c,sideboxs}


)
for ((i=0;i<${#s_directory[@]};i++));do
{
        [ -d ${s_directory[$i]} ] && { chown -R www-data:www-data ${s_directory[$i]} ;chmod 775 ${s_directory[$i]} ;}
}
done
