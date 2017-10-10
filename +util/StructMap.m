%map which should be compatible with struct.  Backed by containers.Map
classdef StructMap
  properties
    map = containers.Map;
  end
  
  methods
    function obj = StructMap(varargin)
      if nargin == 1 && isstruct(varargin{1})
        obj.map = containers.Map;
        s = varargin{1};
        snms = fieldnames(s);
        for i=1:length(snms)
          snm = snms{i};
          obj.map(snm) = s.(snm);
        end
      else
        obj.map = containers.Map(varargin{:});
      end
    end
    
    function varargout = subsref(obj, s)
      switch(s(1).type)
        case '()'
          if length(s) > 1
            [varargout{1:nargout}] = subsref(obj, s(2:end));
          elseif nargout >= 1
            varargout{1} = obj;
          end
        case '{}'
          varargout = cell(1, nargout);
          for i=1:nargout
            varargout{i} = obj.(s.subs{i});
          end
        case '.'
          subv = s(1).subs;
          if ~startsWith(subv, 'map')
            s(1).type = '()';
            s(1).subs = {subv};
            s = [substruct('.', 'map') s];
          end
          [varargout{1:nargout}] = builtin('subsref', obj, s);
      end
    end
    
    function obj = subsasgn(obj, s, r)
      switch(s(1).type)
        case {'()' '{}'}
          error('util.StructMap: Unsupported subsasgn type ''%s''', s(1).type);
        case '.'
          subv = s(1).subs;
          if ~startsWith(subv, 'map')
            s(1).type = '()';
            s(1).subs = {subv};
            s = [substruct('.', 'map') s];
          end
          obj = builtin('subsasgn', obj, s, r);
      end
    end
    
    function names = fieldnames(obj)
      names = keys(obj.map);
    end
    
    function s = rmfield(s, field)
      remove(s.map, field);
    end
  end
end