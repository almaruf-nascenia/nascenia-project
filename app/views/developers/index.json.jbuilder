json.array!(@developers) do |developer|
  json.extract! developer, :id, :name, :designation, :joining_date, :previous_job_exp
  json.url developer_url(developer, format: :json)
end
