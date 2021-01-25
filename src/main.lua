local function is_function(obj)
  return type(obj) == 'function'
end

local function is_pos(x)
  return x > 0
end

local function to_iter(seq)
  return is_function(seq) and seq or coroutine.wrap(function()
    for i = 1, #seq do
      coroutine.yield(seq[i])
    end
  end)
end

local function range(start,finish,step)
  if not start then
    local i = 1
    return coroutine.wrap(function()
      while true do
        coroutine.yield(i)
        i = i + 1
      end
    end)
  elseif not finish then
    finish, start = start, is_pos(start) and 1 or -1
  end
  step = step or ((start < finish) and 1 or -1)
  return coroutine.wrap(function()
    for i = start, finish, step do
      coroutine.yield(i)
    end
  end)
end

local function doeach(f,seq)
  for v in to_iter(seq) do
    local res, terminate = f(v)
    if terminate then
      return res
    end
  end
end

local log = ngx.say

local function main()
  log('\n---THREAD-TEST-')
  ngx.thread.spawn(function()
    for i in range(10) do
      ngx.sleep(math.random() / 5)
      log('Thread 1: ',i)
    end
  end)
  ngx.thread.spawn(function()
    doeach(function(i)
      ngx.sleep(math.random() / 5)
      log('Thread 2: ',i)
    end,range(10))
  end)
end

main()