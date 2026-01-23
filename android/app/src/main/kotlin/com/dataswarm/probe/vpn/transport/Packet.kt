package com.dataswarm.probe.vpn.transport

import com.dataswarm.probe.vpn.transport.protocol.IP4Header
import com.dataswarm.probe.vpn.transport.protocol.TransportHeader

class Packet(var ipHeader: IP4Header, var transportHeader: TransportHeader, var buffer: ByteArray) {
}