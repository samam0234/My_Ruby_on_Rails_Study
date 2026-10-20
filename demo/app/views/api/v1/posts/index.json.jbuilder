json.posts @posts, partial: "api/v1/posts/post", as: :post
json.meta do
  json.page @page
  json.per @per
  json.total @total
end
