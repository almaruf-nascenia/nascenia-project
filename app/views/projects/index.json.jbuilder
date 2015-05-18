json.array!(@projects) do |project|
  json.extract! project, :id, :name, :title, :description
  json.url project_url(project, format: :json)
end
