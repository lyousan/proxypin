package com.dataswarm.forager.vpn.transport

import com.dataswarm.forager.vpn.transport.protocol.IP4Header
import com.dataswarm.forager.vpn.transport.protocol.TransportHeader

class Packet(var ipHeader: IP4Header, var transportHeader: TransportHeader, var buffer: ByteArray) {
}