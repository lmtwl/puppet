<?php
/**
 * 防攻击
 * 单文件，计划任务
 *
 * @Author: Fufu
 * @Update: 2015-08-03
 */

/********************/

$interval = 180;     // 时间间隔（秒）

/********************/


/* 环境设置 */
// error_reporting(0);
date_default_timezone_set('Etc/GMT-8');
header('Content-type:text/html;charset=utf-8');
$root = dirname(__FILE__) . DIRECTORY_SEPARATOR;

/* 仅允许本地执行（不需要请注释下一行） */
// $allow_ip = array('0.0.0.0', '127.0.0.1', '221.237.152.64');
// in_array(get_ip(), $allow_ip) or exit('404');

/* 初始化SoapClient对象 */
$ws = new SoapClient('/usr/local/etc/serviceforweb20001.xml');

/* 参数列表 */
$params = array(
    'command'               => 'Security.GetIPBlockList',
    'userid'                => 0,
    'requestParameters'     => array(
        array('Key' => 'client_ip', 'Value' => '192.168.77.1'),
        array('Key' => 'webserver_dns', 'Value' => 'my.xunyou.com'),
        array('Key' => 'webserver_url', 'Value' => 'http://my.xunyou.com/'),
        array('Key' => 'webserver_HTTP_X_FORWARDED_FOR', 'Value' => ''),
        array('Key' => 'client_remote_addr', 'Value' => '192.168.77.1'),
        array('Key' => 'webserver_ip', 'Value' => '192.168.77.1'),
        array('Key' => 'interval', 'Value' => $interval)
    )
);

/* 执行 */
try {

    /* 调用服务器提供的接口 */
    $res = $ws->Execute($params);
    $data = '';

    /* 执行成功且能正常解析 */
    // $data = $xml->ROWDATA[0]->children();
    if (
        !($ret[1] = $res->ExecuteResult) &&
        ($xml = simplexml_load_string($res->list)) &&
        ($data = $xml->ROWDATA->ROW)
    ) {
        $i = 0;
        foreach ($data as $row) {
            foreach ($row->attributes() as $d) {
                // $ret[0][$i][] = reset($d);
                echo reset($d) . "\n";
            }
            $i++;
        }
    } else {
        // echo $ret[1] . '.fail or null<br />';
    }

} catch (SoapFault $fault) {
    exit('error.');
}

unset($ws, $res);

exit();



/* 函数 */

// 获取客户端 IP (TCP)
function get_ip($tolong = 0, $md5 = 0)
{
    ($ip = $_SERVER['REMOTE_ADDR']) || ($ip = getenv('REMOTE_ADDR'));
    $ip == '::1' && $ip = '127.0.0.1';
    $tolong && $ip = get_ip2long($ip);
    $md5 == 1 && $ip = md5($ip);
    $md5 == 2 && $ip = get_md5($ip);

    return $ip;
}
