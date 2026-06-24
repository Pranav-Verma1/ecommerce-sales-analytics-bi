from load_orders import load_orders
from load_customers import load_customers
from load_products import load_products
from load_carriers import load_carriers

from refresh_warehouse import refresh_warehouse


orders_changed = load_orders()
customers_changed = load_customers()
products_changed = load_products()
carriers_changed = load_carriers()

if any([
    orders_changed,
    customers_changed,
    products_changed,
    carriers_changed
]):
    refresh_warehouse()
else:
    print("\nNo file changes detected.")
    print("Skipping warehouse refresh.")

print("\nETL COMPLETED SUCCESSFULLY")