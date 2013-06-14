#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'
require 'yaml'


class LIMS
  TOKEN = 'dfa3fae1bc88f00a34de3d9c5a3ecd6b'

  def initialize()
    @base_url = "http://limskc01/zanmodules"
    @group = "molbio"
    @type = "ngs"
  end

  def call(resource, command, params)
    url = URI.parse("#{@base_url}/#{@group}/api/#{@type}/#{resource}/#{command}")
    req = Net::HTTP::Post.new(url.path, initheader = {'Content-Type' => 'application/json'})
    req.basic_auth 'apitoken', TOKEN
    req.body = params.to_json
    resp = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
    JSON.parse(resp.body)
  end

  def join_samples_libraries(samples, libs)
    hashed_libs = {}
    libs.each {|lib| hashed_libs[lib['sampleId']] = lib}

    samples_libs = samples.collect do |sample|
      sample_lib = hashed_libs[sample['sampleId']]
      if !sample_lib
        puts "ERROR: cannot find library for sample: #{sample['sampleId']}"
      end

      sample['library'] = sample_lib
      sample
    end
    samples_libs
  end

  def add_samples flowcell
    flowcell["lanes"].each do |lane|
      if lane["itemType"] == "POOL"
        lane['samples'] = pool(lane["itemId"])
      elsif lane["itemType"] == "LIB"
        lane['samples'] = [library(lane["itemId"])]
      else
        puts "ERROR: unknown lane type: #{lane["itemType"]}"
        exit(1)
      end
    end
  end

  def flowcell(flowcell_id, options = {:add_samples => true})
    resource = "flowcells"
    command = "getFlowcell"
    params = {"fcIdent" => order_id}

    flowcell = self.call(resource, command, params)
    if options[:add_samples]
      add_samples(flowcell)
    end

    flowcell
  end

  def flowcells order_id, options = {:add_samples => true}
    resource = "orders"
    command = "getFlowcells"
    params = {"orderId" => order_id}

    flowcells = self.call(resource, command, params)

    if options[:add_samples]
      flowcells.each do |flowcell|
        add_samples(flowcell)
      end
    end
    flowcells
  end

  def order order_id, options = {:add_flowcells => true}
    resource = "orders"
    command = "getOrder"
    params = {"orderId" => order_id}

    order = self.call(resource, command, params)
    if options[:add_flowcells]
      order["flowcells"] = flowcells(order_id)
    end
    order
  end

  def pool pool_id
    resource = "orders"
    command = "getPool"
    params = {"poolId" => pool_id}

    pool = self.call(resource, command, params)
    libraries = []
    pool['libraryIds'].each do |p|
      libraries << library(p)
      libraries[-1].merge! sample(libraries[-1]['sampleId'])
    end
    libraries
  end

  def library lib_id
    resource = "orders"
    command = "getLibrary"
    params = {"libId" => lib_id}

    library = self.call(resource, command, params)
    # library['sample'] = sample(library['sampleId'])
    library.merge! sample(library['sampleId'])
    library
  end

  def sample sample_id
    resource = "orders"
    command = "getSample"
    params = {"sampleId" => sample_id}
    self.call(resource, command, params)
  end

  def samples(order_id, include_lib = true)
    resource = "orders"
    command = "getSamples"
    params = {"orderId" => order_id}

    samples = self.call(resource, command, params)
    if include_lib
      libs = self.libraries(order_id)
    end
    out = join_samples_libraries(samples, libs)
    out
  end

  def libraries(order_id, pooled = true)
    resource = "orders"
    command = "getLibraries"
    params = {"orderId" => order_id, "includePooledLibs" => pooled}

    self.call(resource, command, params)
  end
end

