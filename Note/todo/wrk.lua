function split(source, delimiters)
    local elements = {}
    local pattern = '([^'..delimiters..']+)'
    string.gsub(source, pattern, function(value) elements[#elements + 1] =     value;  end);
    return elements
end

function loadCsvFile(filePath)  
    -- 读取文件  
    local file = io.open(filePath, 'r')
    local data = file:read("*a")
    -- local data = FileUtils:getInstance():getStringFromFile(filePath);  
    -- 按行划分  
    local lineStr = split(data, '\n');  

    local tableHeader = split(lineStr[1], ",");

    local ID = 1;  
    local arrs = {};  
    for i = 1, #lineStr, 1 do  
        -- 一行中，每一列的内容  
        local content = split(lineStr[i], ",");  
        arrs[ID] = {};  
        for j = 1, #tableHeader, 1 do  
            arrs[ID][j] = content[j];  
        end  
        ID = ID + 1;  
    end  
    return arrs;  
end 

function init(args)
    filePath = args[1]
    wrk.data = loadCsvFile(filePath)
end

wrk.method = "POST"
wrk.headers["Content-Type"] = "application/x-www-form-urlencoded"
wrk.line = 2


function toHex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

function request()
    local tableHeader = wrk.data[1]

    local body_val = ""    
    print()
    for j = 1, #tableHeader , 1 do
        local val = "&" .. tableHeader[j] .. "=" .. wrk.data[wrk.line][j]
        body_val =  body_val .. val
    end
   
    wrk.line = (wrk.line + 1) % #wrk.data

    return wrk.format(wrk.method, nil, wrk.headers, body_val)
 end


function response(status, headers, body)
   print(body)
end
