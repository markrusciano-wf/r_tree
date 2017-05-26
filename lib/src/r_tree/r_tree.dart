/*
 * Copyright 2015 Workiva Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

part of r_tree;

typedef bool RTreeTest<E>(RTreeDatum<E> item);

class RTree<E> {
  Node _root;
  int _branchFactor;

  RTree([int branchFactor = 16]) {
    if (branchFactor < 3) {
      throw new ArgumentError('branchFactor must be greater than 2');
    }
    _branchFactor = branchFactor;
    _resetRoot();
  }

  void remove(RTreeDatum<E> item) {
    _root.remove(item);

    if (_root.children.length == 0) {
      _resetRoot();
    }
  }

  void insert(RTreeDatum<E> item) {
    Node splitNode = _root.insert(item);

    if (splitNode != null) {
      _growTree(_root, splitNode);
    }
  }

  _resetRoot() {
    _root = new LeafNode(_branchFactor);
  }

  /// Returns all items whose rectangles overlap the [searchRect] that satisfy [test]
  /// Note: Rectangles that share only a border are not considered to overlap
  /// If [test] is not specified, a test function that always returns true will be used
  Iterable<RTreeDatum<E>> search(Rectangle searchRect, {RTreeTest<E> test}) {
    // If a test is not given, use a test function that always returns true
    test = test ?? (_) => true;

    if (_root is LeafNode) {
      return _root.search(searchRect, test).toList();
    }

    return _root.search(searchRect, test);
  }

  _growTree(Node node1, Node node2) {
    NonLeafNode newRoot = new NonLeafNode(_branchFactor);
    newRoot.addChild(node1);
    newRoot.addChild(node2);
    _root = newRoot;
  }
}
