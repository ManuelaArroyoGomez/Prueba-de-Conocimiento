const API = '/api/items.php'

export async function listItems() {
    const r  = await fetch(API)
    if (!r.ok) throw new Error('Error en la lista')
    return r.json()    
}

export async function createItem(data) {
    const r  = await fetch(API, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({nombre: data.nombre, descripcion: data.descripcion, completado: !!data.completado})
    });
    if (!r.ok) throw new Error('Error al crear la tarea');
    return r.json()    
}

export async function updateItem(id, data) {
    const r  = await fetch(`${API}?id=${id}`, {
        method: 'PUT',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({nombre: data.nombre, descripcion: data.descripcion, completado: !!data.completado})
    });
    if (!r.ok) throw new Error('Error al actualizar la tarea');
    return r.json()    
}

export async function deleteItem(id) {
    const r  = await fetch(`${API}?id=${id}`, {
        method: 'DELETE'
    });
    if (!r.ok) throw new Error('Error al eliminar la tarea');
    return r.json()    
}

export async function toggleCompleted(id, completado) {
    const r  = await fetch(`${API}?id=${id}`, {
        method: 'PATCH',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({completado})
    });
    if (!r.ok) throw new Error('Error en el cambiar del estado');
    return r.json()    
}