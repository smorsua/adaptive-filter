function x = load_dec_txt(filepath, T)
    fid = fopen(filepath, "r");
    x_unsigned = uint16(fscanf(fid, "%d\n"));
    x = reinterpretcast(x_unsigned, T);
    fclose(fid);
end