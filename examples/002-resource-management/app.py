from fastapi import FastAPI

app = FastAPI()

@app.get('/')
def read_root():
    return {'hello': 'world'}

# 🔥 CPU-bound
@app.get('/cpu-bound')
def consume_cpu():
    x = 0
    for i in range(10**8):
        x += i
    return {"result": x}

# 💥 Memory leak
memory_holder = []

@app.get('/memory')
def consume_memory():
    # adding ~10MB for each request
    chunk = "x" * (10 * 1024 * 1024)
    memory_holder.append(chunk)

    return {
        "chunks": len(memory_holder),
        "approx_mb": len(memory_holder) * 10
    }
