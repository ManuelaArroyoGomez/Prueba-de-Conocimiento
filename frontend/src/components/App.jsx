import { useEffect, useMemo, useState } from 'react'
import { listItems, createItem, updateItem, deleteItem, toggleCompleted } from '../api.js'

export default function App() {
    const [items, setItems] = useState([])
    const [form, setForm] = useState({nombre:'', descripcion:'', completado: false})
    const [editingId, setEditingId] = useState(null)
    const [errors, setErrors] = useState({})
    const [filter, setFilter] = useState('all')
    const [search, setSearch] = useState('')

    async function refresh() {
        const data = await listItems()
        setItems(data)
    }
    useEffect(() => {refresh()}, [])

    function validate(values) {
        const e = {}
        if (!values.nombre?.trim()) e.nombre = 'El nombre es obligatorio'
        if (!values.nombre && values.nombre.lenght > 100) e.nombre = 'Maximo 100 caracteres'
        if (!values.descripcion && values.descripcion.lenght > 1000) e.descripcion = 'Maximo 1000 caracteres' 
        return e       
    }

    function onChange(e) {
        const {name, type, checked, value} = e.target
        setForm({...form, [name]: type === 'checkbox' ? checked: value})     
    }

    async function onSubmit(e) {
        e.preventDefault()
        const v = validate(form)
        setErrors(v)
        if (Object.keys(v).length) return
        if (editingId) await updateItem(editingId, form)
        else await createItem(form)
        setForm({ nombre: '', descripcion: '', completado: false })
        setEditingId(null)
        await refresh()
    }

    function onEdit(it) {
    setForm({ nombre: it.nombre, descripcion: it.descripcion || '', completado: !!it.completado })
    setEditingId(it.id)
  }

  async function onDelete(id) {
    if (!confirm('¿Eliminar esta tarea?')) return
    await deleteItem(id)
    await refresh()
  }

  async function onToggle(it) {
    try {
      if (toggleCompleted) {
        await toggleCompleted(it.id, it.completado ? 0 : 1)
      } else {
        await updateItem(it.id, { ...it, completado: it.completado ? 0 : 1 })
      }
      await refresh()
    } catch (e) { console.error(e) }
  }

  const filtered = useMemo(() => {
    let r = items
    if (filter === 'active') r = r.filter(i => !i.completado)
    if (filter === 'done') r = r.filter(i => !!i.completado)
    if (search.trim()) {
      const q = search.toLowerCase()
      r = r.filter(i => (i.nombre||'').toLowerCase().includes(q) || (i.descripcion||'').toLowerCase().includes(q))
    }
    return r
  }, [items, filter, search])

  const total = items.length
  const done = items.filter(i => !!i.completado).length
  const active = total - done

  return (
    <div className="container">
      <header>
        <div className="brand">
          <span className="badge">Tareas</span>
          <h1>Tu lista</h1>
          <small>{active} por hacer • {done} hechas</small>
        </div>
        <div className="toolbar">
          <input className="input" placeholder="Buscar..." value={search} onChange={e=>setSearch(e.target.value)} style={{minWidth:220}} />
          <select className="select" value={filter} onChange={e=>setFilter(e.target.value)}>
            <option value="all">Todas</option>
            <option value="active">Pendientes</option>
            <option value="done">Completadas</option>
          </select>
        </div>
      </header>

      <div className="grid">
        <section className="card panel">
          <h3>{editingId ? 'Editar tarea' : 'Nueva tarea'}</h3>
          <form onSubmit={onSubmit}>
            <label className="label">Título *</label>
            <input className="input" name="nombre" value={form.nombre} onChange={onChange} placeholder="Ej: Entregar informe" />
            {errors.nombre && <small style={{color:'#fca5a5'}}>{errors.nombre}</small>}
            <br/><br/>
            <label className="label">Descripción</label>
            <textarea className="textarea" name="descripcion" value={form.descripcion} onChange={onChange} placeholder="Detalles opcionales"></textarea>
            {errors.descripcion && <small style={{color:'#fca5a5'}}>{errors.descripcion}</small>}
            <br/><br/>
            <label style={{display:'flex',gap:8,alignItems:'center'}}>
              <input type="checkbox" name="completado" checked={!!form.completado} onChange={onChange} />
              Marcar como completada
            </label>
            <br/>
            <button className="btn" type="submit">{editingId ? 'Guardar cambios' : 'Crear tarea'}</button>
            {editingId && <button type="button" className="btn secondary" style={{marginLeft:8}} onClick={()=>{ setEditingId(null); setForm({ nombre:'', descripcion:'', completado:false })}}>Cancelar</button>}
          </form>
        </section>

        <section className="card panel">
          <h3>Listado</h3>
          <table className="table">
            <thead>
              <tr><th></th><th>Tarea</th><th>Descripción</th><th>Estado</th><th>Acciones</th></tr>
            </thead>
            <tbody>
              {filtered.map(it => (
                <tr key={it.id}>
                  <td>
                    <input type="checkbox" checked={!!it.completado} onChange={()=>onToggle(it)} title="Completar" />
                  </td>
                  <td style={{textDecoration: it.completado ? 'line-through' : 'none', opacity: it.completado ? .65 : 1}}>{it.nombre}</td>
                  <td style={{opacity: it.completado ? .6 : 1}}>{it.descripcion || '-'}</td>
                  <td>{it.completado ? <span className="badge">Hecha</span> : <span className="badge" style={{borderColor:'rgba(250,204,21,.3)', background:'rgba(250,204,21,.12)', color:'#facc15'}}>Pendiente</span>}</td>
                  <td>
                    <div style={{display:'flex', gap:8}}>
                      <button className="btn secondary" onClick={()=>onEdit(it)}>Editar</button>
                      <button className="btn danger" onClick={()=>onDelete(it.id)}>Eliminar</button>
                    </div>
                  </td>
                </tr>
              ))}
              {!filtered.length && <tr><td colSpan="5" style={{color:'#9ca3af'}}>No hay tareas para este filtro.</td></tr>}
            </tbody>
          </table>
        </section>
      </div>
    </div>
  )
}