from __future__ import annotations
from typing import List, Dict, Tuple
from dotenv import load_dotenv
import os
import sys
import mysql.connector as mysql

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), ".env"))

def get_env(name: str) -> str:
    v = os.getenv(name)
    if v is None or v == "":
        print(f"[config] Falta {name} en .env de analytics", file=sys.stderr)
        sys.exit(1)
    return v

DB_HOST = get_env("DB_HOST")
DB_PORT = int(get_env("DB_PORT"))
DB_USER = get_env("DB_USER")
DB_PASS = get_env("DB_PASS")
DB_NAME = get_env("DB_NAME")

def fetchReporte() -> List[Dict]:
    try:
        conexion = mysql.connect(
            host=DB_HOST, port=DB_PORT, user=DB_USER, password=DB_PASS, database=DB_NAME
        )
        cur = conexion.cursor(dictionary=True)
        cur.execute("SELECT nombre, email, total FROM vw_reporte_clientes;")
        rows = cur.fetchall()
        cur.close()
        conexion.close()
        return rows
    except mysql.Error as e:
        print(f"[DB] Error de conexion/consulta: {e}", file=sys.stderr)
        return []

def calcularPromedioTop3(rows: List[Dict], incluir_ceros: bool = False) -> Tuple[float, List[Dict]]:
    if not rows:
        return 0.0, []
    norm = [{**r, "total": float(r.get("total", 0) or 0)} for r in rows]
    considerados = norm if incluir_ceros else [r for r in norm if r["total"] > 0]
    if not considerados:
        return 0.0, []
    promedio = sum(r["total"] for r in considerados) / len(considerados)
    top3 = sorted(considerados, key=lambda r: r["total"], reverse=True)[:3]
    return promedio, top3

def tabla(rows: List[Dict], title: str) -> None:
    print(f"\n{title}")
    print("-" * 80)
    print(f"{'Cliente':25} | {'Email':26} | {'Total':>10}")
    print("-" * 80)
    for r in rows:
        nombre = str(r.get('nombre', ''))[:25]
        email  = str(r.get('email', ''))[:26]
        total  = float(r.get('total', 0) or 0)
        print(f"{nombre:25} | {email:26} | {total:10.2f}")

def main():
    rows = fetchReporte()
    if not rows:
        print("No hay datos para analizar.")
        return
    tabla(rows, "Reporte por cliente")
    print("-" * 80)
    promedio, top3 = calcularPromedioTop3(rows, incluir_ceros=False)
    print(f"\nPromedio del valor total de pedido: {promedio:.2f}\n")
    tabla(top3, "Top 3 clientes por valor total")
    print("-" * 80)

if __name__ == "__main__":
    main()