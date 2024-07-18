function x = load_dec_txt(filepath, T)
    fid = fopen(filepath, "r");
    x = fi(0,T);
    input = fscanf(fid, "%ld\n");
    x.int = input;
    fclose(fid);
end