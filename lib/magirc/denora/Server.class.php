<?php
// $Id$

class Server extends Denora {

    function __construct($name) {
        #parent::__construct();
        $this->db = new Denora_DB();
        $server = $this->getServer($name);
        if ($server) {
            $this->id = $server['servid'];
            $this->name = $server['server'];
            $this->hops = $server['hops'];
            $this->description = $server['comment'];
            $this->linked_to_id = $server['linkedto'];
            $this->connecttime = strtotime($server['connecttime']);
            $this->online = $server['online'] == 'Y' ? true : false;
            $this->lastsplit = strtotime($server['lastsplit']);
            $this->version = $server['version'];
            $this->uptime = $server['uptime'];
            $this->motd = $server['motd'];
            $this->currentusers = $server['currentusers'];
            $this->maxusers = $server['maxusers'];
            $this->maxusertime = $server['maxusertime'];
            $this->ping = $server['ping'];
            $this->pingtime = $server['lastpingtime'];
            $this->maxping = $server['highestping'];
            $this->maxpingtime = $server['maxpingtime'];
            $this->uline = $server['uline'] ? true : false;
            $this->operkills = $server['ircopskills'];
            $this->serverkills = $server['serverkills'];
            $this->opers = $server['opers'];
            $this->maxopers = $server['maxopers'];
            $this->maxopertime = $server['maxopertime'];
        }
    }

    private function getServer($name) {
        $server = $this->db->selectOne('server', array('server' => $name));
        return @$server;
    }

    /*function getServers() {
            return $this->db->selectAll('server', NULL, 'server', 'ASC');
    }*/

}

?>