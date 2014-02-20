json.array!(@users) do |user|
  json.extract! user, :id, :user, :password, :count
  json.url user_url(user, format: :json)
end