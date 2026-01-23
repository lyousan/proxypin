package com.dataswarm.probe.vpn.socket

import com.dataswarm.probe.vpn.Connection

interface CloseableConnection {
    /**
     * 关闭连接
     */
    fun closeConnection(connection: Connection)
}