package edis.storage.fs.async;

import edis.storage.fs.async.impl.IReadStream;

@:forward
abstract FileReadStream (IFileReadStream) from IFileReadStream to IFileReadStream {
    public inline function new(i: IFileReadStream) {
        this = i;
    }

    @:allow( edis.storage.fs.async.impl.IReadStream.IFileReadStream )
    private static inline function fromImpl<T:IFileReadStream>(i: T):FileReadStream {
        return new FileReadStream( i );
    }
}
