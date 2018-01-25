package edis.storage.fs.async.impl;

import tannus.io.*;
import tannus.ds.*;
import tannus.ds.tuples.*;
import tannus.sys.Path;
import tannus.async.*;
import tannus.async.promises.*;

import tannus.node.Buffer;
import tannus.node.Fs;
import tannus.node.Process;
import tannus.node.Error;

import edis.storage.fs.async.impl.IReadStream;

import Slambda.fn;

import haxe.Serializer;
import haxe.Unserializer;

import edis.Globals.*;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.async.Asyncs;

class NodeFileSystemImpl extends FileSystemImpl {
    /* Constructor Function */
    public function new():Void {
        super();
    }

/* === Instance Methods === */

    /**
      *
      */
    override function exists(path:Path, ?callback:Cb<Bool>):BoolPromise {
        return Promise.create({
            Fs.exists(ps(path), function(res: Bool):Void {
                return res;
            });
        }).toAsync( callback ).bool();
    }

    override function isDirectory(path:Path, ?callback:Cb<Bool>):BoolPromise {
        return Fs.stat.bind(ps(path), _).toPromise().transform(function(stat) {
            return stat.isDirectory();
        }).toAsync( callback ).bool();
    }

    override function createDirectory(path:Path, ?done:VoidCb):VoidPromise {
        return Fs.mkdir.bind(ps(path), _).toPromise().toAsync( done );
    }

    override function deleteDirectory(path:Path, ?done:VoidCb):VoidPromise {
        return Fs.rmdir.bind(ps(path), _).toPromise().toAsync( done );
    }

    override function deleteFile(path:Path, ?done:VoidCb):VoidPromise {
        return Fs.unlink.bind(ps(path), _).toPromise().toAsync( done );
    }

    override function rename(oldPath:Path, newPath:Path, ?callback:Cb<Path>):Promise<Path> {
        return new Promise<Path>(function(accept, reject) {
            Fs.rename(ps(oldPath), ps(newPath), function(?error) {
                if (error != null) {
                    //TODO
                    reject( error );
                }
                else {
                    accept( newPath );
                }
            });
        }).toAsync( callback );
    }

    override function copy(src:Path, dest:Path, ?callback:Cb<Path>):Promise<Path> {
        return new Promise<Path>(function(accept, reject) {
            try {
                Fs.copyFile(ps(src), ps(dest), function(?error) {
                    if (error != null) {
                        reject( error );
                    }
                    else {
                        accept( dest );
                    }
                });
            }
            catch (error: TypeError) {
                if (error.message.endsWith('is not a function')) {
                    Fs.readFile(ps(src), function(?error, ?data:Buffer) {
                        if (error != null) {
                            reject( error );
                        }
                        else if (data != null) {
                            Fs.writeFile(ps(dest), data, null, function(?error) {
                                if (error != null) {
                                    reject( error );
                                }
                                else {
                                    accept( dest );
                                }
                            });
                        }
                    });
                }
                else {
                    reject( error );
                }
            }
            catch (error: Dynamic) {
                reject( error );
            }
        }).toAsync( callback );
    }

    override function read(path:Path, ?offset:Int, ?length:Int, ?done:Cb<ByteArray>):Promise<ByteArray> {
        return new Promise<ByteArray>(function(accept, reject) {
            if (offset == null && length == null) {
                accept(untyped Fs.readFile.bind(ps(path), _).toPromise().transform(x->fb(x)));
            }
            else {
                Fs.open(ps(path), 'r', function(?error, ?fid) {
                    if (error != null) {
                        reject( error );
                    }
                    else if (fid != null) {
                        if (offset == null)
                            offset = 0;
                        function do_read() {
                            var buff:Buffer = new Buffer( length );
                            Fs.read(fid, buff, 0, length, offset, function(?err, ?bytesRead:Int, ?buffer:Buffer) {
                                if (bytesRead < buffer.length) {
                                    buffer = buffer.slice(0, bytesRead);
                                }
                                Fs.close(fid, function(?error) {
                                    if (error != null) {
                                        reject( error );
                                    }
                                    else {
                                        accept(fb( buffer ));
                                    }
                                });
                            });
                        }
                        if (length == null) {
                            Fs.stat(ps(path), function(?error, ?stat) {
                                if (error != null) {
                                    reject( error );
                                }
                                else {
                                    length = stat.size;
                                    do_read();
                                }
                            });
                        }
                        else {
                            do_read();
                        }
                    }
                });
            }
        }).toAsync( done );
    }

    override function readDirectory(path:Path, ?done:Cb<Array<String>>):ArrayPromise<String> {
        return Fs.readdir.bind(ps(path), _).toPromise().toAsync( done ).array();
    }

    override function write(path:Path, data:FileWriteData, ?callback:VoidCb):VoidPromise {
        return Fs.writeFile.bind(ps(path), tb(data.toByteArray()), null, _).toPromise().toAsync( callback );
    }

    override function stat(path:Path, ?done:Cb<FileStat>):Promise<FileStat> {
        return Fs.stat.bind(ps(path), _).toPromise().transform(function(stat: Stats):FileStat {
            return {
                size: stat.size,
                ctime: stat.ctime,
                mtime: stat.mtime
            };
        }).toAsync( done );
    }

    override function truncate(path:Path, len:Int, ?done:VoidCb):VoidPromise {
        return Fs.truncate.bind(ps(path), len, _).toPromise().toAsync( done );
    }

    override function createReadStream(path:Path, ?options:CreateFileReadStreamOptions, ?callback:Cb<IFileReadStream>):Promise<IFileReadStream> {
        return new Promise<IFileReadStream>(function(accept, reject) {
            var topts = rstreamOptions( options );
            var ns = Fs.createReadStream(ps(path), topts._0);
            var res = new NodeFileReadStreamImpl( ns );
            res.setOptions( topts._1 );
            res.open();
            accept( res );
        }).toAsync( callback );
    }

    /**
      * convert a Path to a String
      */
    private function ps(path: Path):String {
        return path.toString();
    }

    /**
      * convert a Buffer to a ByteArray
      */
    private function fb(buffer: Buffer):ByteArray {
        return ByteArray.ofData( buffer );
    }

    private function tb(bytes: ByteArray):Buffer {
        return bytes.getData();
    }

    private function rstreamOptions(?o: CreateFileReadStreamOptions):Tup2<Null<CreateReadStreamOptions>, FileReadStreamOptions> {
        if (o == null)
            return new Tup2(null, {
                autoClose: true,
                forceAsync: false
            });
        var nso:CreateReadStreamOptions={};
        var so:FileReadStreamOptions = {
            autoClose: true,
            forceAsync: false
        };
        var t = new Tup2(nso, so);
        if (o.start != null) {
            nso.start = so.start = o.start;
        }
        if (o.end != null) {
            nso.end = so.start = o.end;
        }
        if (o.autoClose != null) {
            nso.autoClose = so.autoClose = o.autoClose;
        }
        if (o.forceAsync != null)
            so.forceAsync = o.forceAsync;
        so.chunkSize = o.chunkSize;
        return t;
    }
}
