package edis.storage.fs;

typedef FileStat = {
    size: Int,
    ?mtime: Date,
    ?ctime: Date
};
