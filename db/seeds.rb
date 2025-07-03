# Seed a county
county = County.find_or_initialize_by(name: "Aveiro")
county.update!(
  latitude: 40.640355,
  longitude: -8.652696
)

# Seed providers
providers = [ "BUGA" ]
providers.each do |p_name|
  provider = Provider.find_or_initialize_by(name: p_name)
  provider.update!(name: p_name)
  county.providers << provider unless county.providers.exists?(provider.id)
end

# Seed stations
stations = [
  { name: "Esgueira (Carramona)", latitude: "40.6488", longitude: "-8.63106", capacity: "13" },
  { name: "Estação CP Nascente", latitude: "40.6435", longitude: "-8.63988", capacity: "13" },
  { name: "Estação CP Poente", latitude: "40.6432", longitude: "-8.64106", capacity: "25" },
  { name: "Avenida 5 de Outubro", latitude: "40.642", longitude: "-8.64619", capacity: "13" },
  { name: "Cais do Côjo (Loja Buga)", latitude: "40.6417", longitude: "-8.64981", capacity: "13" },
  { name: "Praça da República", latitude: "40.6407", longitude: "-8.65402", capacity: "8" },
  { name: "Rabumba", latitude: "40.6409", longitude: "-8.65555", capacity: "8" },
  { name: "Praça M. de Pombal", latitude: "40.6379", longitude: "-8.65374", capacity: "13" },
  { name: "Parque da Cidade", latitude: "40.636", longitude: "-8.65287", capacity: "8" },
  { name: "Estacionamento do Hospital", latitude: "40.6348", longitude: "-8.65617", capacity: "25" },
  { name: "Ponte Pedonal UA", latitude: "40.6283", longitude: "-8.65632", capacity: "13" },
  { name: "ISCAA UA", latitude: "40.6307", longitude: "-8.65305", capacity: "13" },
  { name: "Bombeiros Velhos", latitude: "40.6323", longitude: "-8.64952", capacity: "8" },
  { name: "Bairro de Santiago", latitude: "40.627", longitude: "-8.64931", capacity: "8" },
  { name: "Glicínias", latitude: "40.6269", longitude: "-8.64675", capacity: "13" },
  { name: "Avenida de Oita", latitude: "40.6353", longitude: "-8.64803", capacity: "8" },
  { name: "Avenida 25 de Abril", latitude: "40.6374", longitude: "-8.64833", capacity: "13" },
  { name: "Fonte Nova (Norte)", latitude: "40.6405", longitude: "-8.64673", capacity: "8" },
  { name: "Cais da Fonte Nova", latitude: "40.6384", longitude: "-8.64376", capacity: "8" },
  { name: "Forca (Rotunda)", latitude: "40.639", longitude: "-8.64004", capacity: "13" }
]

stations.each do |s|
  station = Station.find_or_initialize_by(name: s[:name])
  station.update!(
    latitude: s[:latitude].to_f,
    longitude: s[:longitude].to_f,
    max_capacity: s[:capacity].to_i,
    county: county
  )
end

# Seed Customers
customers = [
  { email: "residente@example.com", username: "Joao", id_card_number: "12345678" },
  { email: "visitante@example.com", username: "Maria", id_card_number: nil },
  { email: "ana@example.com", username: "Ana", id_card_number: "11223344" }
]

customers.each do |c|
  user = User.find_or_initialize_by(email_address: c[:email])
  user.password = "123456"
  user.password_confirmation = "123456"
  user.save!

  customer = Customer.find_or_initialize_by(user: user)
  customer.update!(
    username: c[:username],
    id_card_number: c[:id_card_number],
    status: :active,
    balance: 0.0
  )
end


# Seed bikes
Bike.delete_all

bike_types = [
  { brand: "Urban 3000", pricing: 0.15 },
  { brand: "MTB Pro", pricing: 0.25 }
]

stations = Station.all.index_by(&:id)
station_ids = stations.keys
max_total_bikes = 100
bike_index = 0
created_bikes = 0

# Track per-station bike count caps
station_limits = stations.transform_values do |station|
  (station.max_capacity * 0.8).floor
end

# Initialize current counts to 0
station_counts = Hash.new(0)

while created_bikes < max_total_bikes
  break if station_ids.empty?

  station_id = station_ids.sample
  limit = station_limits[station_id]

  if station_counts[station_id] >= limit
    station_ids.delete(station_id)
    next
  end

  type = bike_types[bike_index % bike_types.size]

  Bike.create!(
    station_id: station_id,
    brand: type[:brand],
    total_kms: 0.0,
    pricing: type[:pricing],
    status: :available
  )

  station_counts[station_id] += 1
  created_bikes += 1
  bike_index += 1
end
