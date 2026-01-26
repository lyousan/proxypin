package com.dataswarm.forager.vpn.socket

import com.dataswarm.forager.vpn.Connection

interface CloseableConnection {
    /**
     * 关闭连接
     */
    fun closeConnection(connection: Connection)
}