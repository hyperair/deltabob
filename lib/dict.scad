function dict (kv_tuples) = kv_tuples;

function dict_has_key (d, key) = search ([key], d)[0] != [];
function dict_get_tuple (d, key) = d[search ([key], d)[0]];
function dict_get (d, key) = dict_get_tuple (d, key)[1];
