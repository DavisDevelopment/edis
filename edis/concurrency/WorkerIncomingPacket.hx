package edis.concurrency;

import tannus.ds.Uuid;
import tannus.ds.Dict;

import haxe.Json as JSON;
import haxe.Serializer;
import haxe.Unserializer;

import edis.concurrency.WorkerPacket;

using StringTools;
using tannus.ds.StringUtils;

typedef WorkerIncomingPacket = edis.concurrency.IPacket;
