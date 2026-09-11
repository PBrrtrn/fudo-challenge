class ProductsRepository
  
  def initialize
    @next_id = 0
    @data = {}
    @mutex = Mutex.new
  end

  def push(name)
    @mutex.synchronize do
      @data[@next_id] = { id: @next_id, name: name }
      @next_id += 1
    end
  end

  def get(id)
    @mutex.synchronize do
      @data[id]
    end
  end
  
  def get_all
    @mutex.synchronize do
      @data.values
    end
  end

end
